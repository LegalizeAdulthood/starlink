      SUBROUTINE IMG1_DLFT( SLOT, ITEM, NOCCUR, STATUS )
*+
* Name:
*    IMG1_DLFTx

*  Purpose:
*    Deletes a FITS record.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL IMG1_DLFTx( SLOT, ITEM, NOCCUR, STATUS )

*  Description:
*     This routine deletes a record in a FITS block which contains the
*     NOCCUR'th occurence of the given FITS keyword. A FITS block must
*     have been already associated with the indicated NDF. If the
*     keyword does not exist then no error is reported.

*  Arguments:
*     SLOT = INTEGER (Given)
*        The slot number of the NDF.
*     ITEM = CHARACTER * ( * ) (Given)
*        The FITS keyword. This may be heirarchical.
*     NOCCUR = INTEGER (Given)
*        The occurence of the FITS keyword which is to be deleted.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK - Durham University)
*     {enter_new_authors_here}

*  History:
*     27-JUL-1994 (PDRAPER):
*        Original version.
*     12-SEP-1994 (PDRAPER):
*        Now doesn't worry about missing items and deals with multiple
*        occurences.
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
      INCLUDE 'NDF_PAR'          ! NDF_ constants
      INCLUDE 'DAT_PAR'          ! HDS/DAT parameters

*  Global Variables:
      INCLUDE 'IMG_ECB'          ! IMG Extension Control Block
*        ECB_FTSP( IMG__MXPAR ) = INTEGER (Read)
*        Pointer to mapped FITS block.
*
*        ECB_FTSN( IMG__MXPAR ) = INTEGER (Read)
*        Number of entries in the FITS block.

      INCLUDE 'IMG_PCB'          ! IMG Parameter Control Block
*        PCB_INDF( IMG__MXPAR ) = INTEGER (Read)
*           NDF identifiers

*  External References:
      EXTERNAL IMG1_INIT         ! Initialise common blocks

*   Arguments Given:
      INTEGER SLOT
      CHARACTER * ( * ) ITEM
      INTEGER NOCCUR

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      LOGICAL DELETE             ! Item has been located in FITS block

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Note the %VAL(80)'s following the last genuine arguments of certain
*  calls. This is the usual method used by compilers for passing the
*  lengths of strings on UNIX and needs to be used here since the
*  characters are mapped.

*  Try to delete the value (this actually results in the record being
*  set blank).
      CALL IMG1_DKEY( ECB_FTSN( SLOT ), %VAL( ECB_FTSP( SLOT ) ),
     :                ITEM, NOCCUR, DELETE, STATUS, %VAL( 80 ) )
      END

* $Id$
