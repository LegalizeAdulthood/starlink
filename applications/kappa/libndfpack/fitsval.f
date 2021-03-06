      SUBROUTINE FITSVAL( STATUS )
*+
*  Name:
*     FITSVAL

*  Purpose:
*     Reports the value of a keyword in the FITS airlock.

*  Language:
*     Starlink Fortran 77

*  Type of Module:
*     ADAM A-task

*  Invocation:
*     CALL FITSVAL( STATUS )

*  Arguments:
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Description:
*     This application reports the value of a keyword in the FITS
*     extension (`airlock') of an NDF file.  The keyword's value and
*     comment are also stored in output parameters.

*  Usage:
*     fitsval ndf keyword

*  ADAM Parameters:
*     COMMENT = LITERAL (Write)
*        The comment of the keyword.
*     KEYWORD = LITERAL (Read)
*        The name of an existing keyword in the FITS extension whose
*        value is to be reported.  A name may be compound to handle
*        hierarchical keywords, and it has the form
*        keyword1.keyword2.keyword3 etc.  The maximum number of keywords
*        per FITS card is 20.  Each keyword must be no longer than 8
*        characters, and be a valid FITS keyword comprising only
*        alphanumeric characters, hyphen, and underscore.  Any
*        lowercase letters are converted to uppercase and blanks are
*        removed before insertion, or comparison with the existing
*        keywords.
*
*        KEYWORD may have an occurrence specified in brackets []
*        following  the name.  This enables editing of a keyword that
*        is not the first occurrence of that keyword, or locate a edited
*        keyword not at the first occurrence of the positional keyword.
*        Note that it is not normal to have multiple occurrences of a
*        keyword in a FITS header, unless it is blank, COMMENT or
*        HISTORY.  Any text between the brackets other than a positive
*        integer is interpreted as the first occurrence.
*     NDF = NDF (Read)
*        The NDF containing the FITS keyword.
*     VALUE = LITERAL (Write)
*        The value of the keyword.

*  Examples:
*     fitsval abc bscale
*        This reports the value of the FITS keyword BSCALE, which is
*        located within the FITS extension of the NDF called abc.
*     fitsval ndf=abc keyword=date[2]
*        This reports the value of the second occurrence FITS keyword
*        DATE, which is located within the FITS extension of the NDF
*        called abc.

*  Related Applications:
*     KAPPA: FITSEDIT, FITSEXIST, FITSHEAD, FITSLIST, FITSMOD.

*  Copyright:
*     Copyright (C) 2005 Particle Physics & Astronomy Research Council.
*     Copyright (C) 2005 Science & Technology Facilities Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either Version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
*     02110-1301, USA.

*  Authors:
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}

*  History:
*     2005 October 6 (MJC):
*        Original version, derived from FITSMOD code.
*     2007 July 16 (MJC):
*        Fix bug where a card string was passed instead of a card index.
*     {enter_further_changes_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'DAT_PAR'          ! Data-system constants
      INCLUDE 'MSG_PAR'          ! MSG__ constants
      INCLUDE 'PAR_ERR'          ! PAR__ error codes
      INCLUDE 'CNF_PAR'          ! For CNF_PVAL function

*  Status:
      INTEGER STATUS             ! Global status

*  External References:
      INTEGER CHR_LEN            ! Significant length of a string

*  Local Constants:
      INTEGER FITSLN             ! No. of characters in a FITS header
      PARAMETER ( FITSLN = 80 )  ! card

      INTEGER HKEYLN             ! Maximum number of characters in a
                                 ! hierarchical FITS keyword
      PARAMETER ( HKEYLN = 48 )

*  Local Variables:
      INTEGER ATEMPT             ! Number of attempts to obtain a
                                 ! valid keyword
      INTEGER CARD               ! Index to header card of the keyword
      CHARACTER * ( 60 ) COMENT ! FITS header card's comment
      INTEGER EL                 ! Number of FITS headers in extension
      INTEGER FTSPNT( 1 )        ! Pointer to mapped FITS X
      INTEGER INDF               ! NDF identifier
      CHARACTER * ( HKEYLN ) KEYS ! Keyword string
      CHARACTER * ( HKEYLN ) KEYWRD ! Edit keyword
      INTEGER KOCCUR             ! Occurrence of edit keyword
      INTEGER LKEY               ! Length of a keyword
      CHARACTER * ( DAT__SZLOC ) LOC ! FITS extension locator
      CHARACTER * ( 70 ) SVALUE  ! Value
      LOGICAL THERE              ! FITS extension already exists?
      LOGICAL VALID              ! Keyword is valid?

*.

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Access the FITS extension.
*  ==========================

*  Obtain the NDF to be probed.
      CALL LPG_ASSOC( 'NDF', 'READ', INDF, STATUS )

*  See whether or not there is a FITS extension.
      CALL NDF_XSTAT( INDF, 'FITS', THERE, STATUS )
      IF ( .NOT. THERE ) THEN
         STATUS = SAI__ERROR
         CALL ERR_REP( 'FITSEXIST_NOEXT',
     :     'There is no FITS extension present.', STATUS )
      ELSE

*  Find the FITS extension.
         CALL NDF_XLOC( INDF, 'FITS', 'READ', LOC, STATUS )
      END IF

*    Abort if the answer is illegal.
      IF ( STATUS .NE. SAI__OK ) GOTO 999

*  Obtain the edit keyword and occurrence.
*  =======================================

*  The edit keyword has to be validated and the occurrence extracted.
*  So perform a DO WHILE loop, but give up after 5 failed attempts.
      ATEMPT = 1
      VALID = .FALSE.
   10 CONTINUE       ! Start of 'DO WHILE' loop.
      IF ( ATEMPT .LT. 5 .AND. .NOT. VALID ) THEN

*  Obtain the keyword definition and its length.
         CALL PAR_GET0C( 'KEYWORD', KEYS, STATUS )
         IF ( STATUS .NE. SAI__OK ) GOTO 999
         LKEY = CHR_LEN( KEYS )

*  Watch for the special case when the keyword is blank.  The
*  subroutine below will take care of a blank followed by brackets.
         IF ( LKEY .EQ. 0 ) THEN
            KEYWRD = ' '
            KOCCUR = 1

         ELSE

*  Extract the uppercase keyword and any occurrence, and find the
*  length of the keyword.  Also validate the keyword.  Use a new error
*  context so that the error can be flushed.
            CALL ERR_MARK
            CALL FTS1_EVKEY( KEYS( :LKEY ), KEYWRD, LKEY, KOCCUR,
     :                       STATUS )

*  Report what went wrong.  Increment the attempt count.
            IF ( STATUS .NE. SAI__OK ) THEN
               CALL ERR_FLUSH( STATUS )
               ATEMPT = ATEMPT + 1
            ELSE
               VALID = .TRUE.
            END IF
            CALL ERR_RLSE
         END IF

*  Return to the head of the 'DO WHILE' loop.
         IF ( .NOT. VALID ) GOTO 10
      END IF

*  Give up.
      IF ( .NOT. VALID ) GOTO 999

*  Print the value.
*  ================

*  Map the 80-character FITS card array.
      CALL DAT_MAPV( LOC, '_CHAR', 'READ', FTSPNT, EL, STATUS )

*  Attempt to locate the keyword's occurrence in the array of FITS cards.
      CALL FTS1_LOKEY( EL, %VAL( CNF_PVAL( FTSPNT( 1 ) ) ), KEYWRD,
     :                 KOCCUR, CARD, STATUS,
     :                 %VAL( CNF_CVAL( FITSLN ) ) )

*  Print the keyword's value.
      CALL FTS1_PRVAL( EL, %VAL( CNF_PVAL( FTSPNT( 1 ) ) ), KEYWRD,
     :                 KOCCUR, CARD, SVALUE, COMENT, STATUS,
     :                 %VAL( CNF_CVAL( FITSLN ) ) )

* Store the value in an output parameter.
      CALL PAR_PUT0C( 'VALUE', SVALUE, STATUS )

* Store the comment in an output parameter.
      CALL PAR_PUT0C( 'COMMENT', COMENT, STATUS )

*  Tidy
*  ====

*  Unmap the FITS array.
      CALL DAT_UNMAP( LOC, STATUS )

  999 CONTINUE

*  Annul (thereby unmapping) locator to the FITS extension.
      CALL DAT_ANNUL( LOC, STATUS )

*  Annul the NDF identifier.
      CALL NDF_ANNUL( INDF, STATUS )

*  If an error occurred, then report a contextual message.
      IF ( STATUS .NE. SAI__OK ) THEN
         CALL ERR_REP( 'FITSVAL_ERR',
     :     'FITSVAL: Error obtaining the value of a FITS keyword '/
     :      /'in an NDF.', STATUS )
      END IF

      END
