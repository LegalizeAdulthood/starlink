      SUBROUTINE IMG_RDHD<T>( PARAM, EXTEN, ITEM, VALUE, STATUS )
*+
*  Name:
*    IMG_RDHD<T>

*  Purpose:
*     Reads a "header" item.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL IMG_RDHDX( PARAM, EXTEN, ITEM, VALUE, STATUS )

*  Description:
*     This routine returns the value of a "header" item. "Header" items
*     include both FITS header records and package specific NDF
*     extension information. The values of FITS header records are
*     extracted by setting the EXTEN argument to the value 'FITS' and
*     ITEM to the required keyword.

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        Parameter name of the NDF whose header items are to be read
*        (case insensitive).
*     EXTEN = CHARACTER * ( * ) (Given)
*        Name of the NDF extension to be read ('FITS' to read a FITS
*        header record).
*     ITEM = CHARACTER * ( * ) (Given)
*        Name of the NDF extension item to be read or the FITS header
*        record keyword.
*     VALUE = <COMM> (Returned)
*        The value.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     - There is a version of this routine for accessing header items
*     of various types. Replace the "x" in the routine name by C, L, D,
*     R, or I as appropriate. If the requested item isn't of the
*     required type automatic conversion will be performed as
*     appropriate.
*
*     - The item names for any extension may be hierarchical
*     (i.e. ING.DETHEAD get the FITS header value for "ING DETHEAD",
*     BOUNDS.MAXX gets the value of the MAXX component of the BOUNDS
*     structure in the named extension).
*
*     - This routine may be used to read the value of named items in
*     the same extension of more than one image dataset at a time by
*     using multiple parameter names. Multiple parameter names are
*     provided as a comma separated list (i.e. 'IN1,IN2,IN3'). Note the
*     extension must exist in all images and that the argument VALUE
*     must be declared as a dimension of size at least the number of
*     parameters in the list, if this option is used.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK - Durham University)
*     {enter_new_authors_here}

*  History:
*     19-JUL-1994 (PDRAPER):
*        Original version.
*     19-AUG-1994 (PDRAPER):
*        Extended to use multiple parameter names.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'IMG_CONST'        ! IMG_ constants
      INCLUDE 'IMG_ERR'          ! IMG_ error codes

*  Arguments Given:
      CHARACTER * ( * ) PARAM
      CHARACTER * ( * ) EXTEN
      CHARACTER * ( * ) ITEM

*  Arguments Returned:
      <TYPE> VALUE( * )

*  Status:
      INTEGER STATUS             ! Global status

*  External References:
      EXTERNAL CHR_SIMLR
      LOGICAL CHR_SIMLR          ! Strings are the same apart from case

*  Local Variables:
      CHARACTER * ( IMG__SZPAR ) VPAR ! Validated parameter name
      INTEGER ESLOT              ! Extension slot number
      INTEGER F                  ! First character position
      INTEGER I1                 ! Position of start of field
      INTEGER I2                 ! Position of end of field
      INTEGER L                  ! Last character positiong
      INTEGER NPAR               ! Number of parameters
      INTEGER SLOT               ! Parameter slot number
      LOGICAL WASNEW             ! Dummy

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Initialise the parameter count.
      NPAR = 0

*  Initialise the character pointer to the start of the parameter list.
*  Then loop to extract each element from the list.
      I1 = 1
 1    CONTINUE                   ! Start of "DO WHILE" loop
      IF ( ( STATUS .EQ. SAI__OK ) .AND. ( I1 .LE. LEN( PARAM ) ) )
     :     THEN

*  Find the final character of the next element in the parameter list
*  (the last character before a comma or end of string).
         I2 = INDEX( PARAM( I1 : ), ',' )
         IF ( I2 .EQ. 0 ) THEN
            I2 = LEN( PARAM )
         ELSE
            I2 = I2 + I1 - 2
         END IF
         IF ( I2 .GE. I1 ) THEN

*  Locate the first and last non-blank characters in the element,
*  checking that it is not entirely blank.
            CALL CHR_FANDL( PARAM( I1 : I2 ), F, L )
            IF ( L .GE. F ) THEN
               F = F + I1 - 1
               L = L + I1 - 1

*  Increment the parameter count.
               NPAR = NPAR + 1

*  Validate the parameter and its slot number.
               CALL IMG1_VPAR( PARAM( F: L ), VPAR, STATUS )
               CALL IMG1_GTSLT( VPAR, .FALSE., SLOT, WASNEW, STATUS )
               IF ( STATUS .EQ. SAI__OK ) THEN

*  Initialise IMG to read the extension (if not already doing so).
                  CALL IMG1_EXINI( SLOT, EXTEN, .FALSE., ESLOT, STATUS )

*  Now branch according to the "type" of extension which we are dealing
*  with. FITS requires its own methods.
                  IF ( CHR_SIMLR( 'FITS', EXTEN ) ) THEN

*  Need to extract the required item from the FITS character array.
                     CALL IMG1_RDFT<T>( SLOT, ITEM, VALUE( NPAR ),
     :                                  STATUS )
                  ELSE

*  Need to locate the named item (which may be hierarchical).
                     CALL IMG1_RDEX<T>( SLOT, ESLOT, ITEM,
     :                                  VALUE( NPAR ), STATUS )
                  END IF
               END IF
            END IF
         END IF

*  Increment the character pointer to the start of the next element in
*  the parameter list and return to process the next element.
         I1 = I2 + 2
         GO TO 1
      END IF

*  If no error has occurred, but no non-blank parameter names have been
*  processed, then report an error.
      IF ( ( STATUS .EQ. SAI__OK ) .AND. ( NPAR .EQ. 0 ) ) THEN
         STATUS = IMG__PARIN
         CALL ERR_REP( 'IMG_RDHD<T>_NOPAR',
     :        'No parameter name specified (possible ' //
     :        'programming error).', STATUS )
      END IF
      END
* $Id$
