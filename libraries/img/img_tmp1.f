      SUBROUTINE IMG_TMP1( PARAM, NX, IP, STATUS )
*+
*  Name:
*     IMG_TMP1

*  Purpose:
*     Creates a temporary 1-dimensional image.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL IMG_TMP1( PARAM, NX, IP, STATUS )

*  Description:
*     This routine creates a temporary 1-dimensional image for use as
*     workspace and returns a pointer to its data, mapped as floating
*     point (REAL) values. The image will be deleted automatically
*     when it is later released (e.g. by calling IMG_FREE).

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        Parameter name (case insensitive).
*     NX = INTEGER (Given)
*        Size of the image (in pixels).
*     IP = INTEGER (Returned)
*        Pointer to the image data.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     - Access to more than one piece of temporary image data is
*     possible using multiple parameter names. These are specified by
*     supplying a comma separated list of names
*     (i.e. 'WORK1,WORK2,WORK3'). A pointer to the data of each image
*     is then returned (in this case the IP argument should be passed
*     as an array of size at least the number of parameter names).

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK, RAL)
*     PDRAPER: Peter Draper (STARLINK - Durham University)
*     {enter_new_authors_here}

*  History:
*     21-FEB-1992 (RFWS):
*        Original version.
*     18-AUG-1994 (PDRAPER):
*        Extended to use multiple parameter names.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'IMG_CONST'        ! IMG_ private constants

*  Arguments Given:
      CHARACTER * ( * ) PARAM
      INTEGER NX

*  Arguments Returned:
      INTEGER IP( * )

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      INTEGER NDIM               ! Number of NDF dimensions
      PARAMETER ( NDIM = 1 )

*  Local Variables:
      INTEGER DIM( NDIM )        ! NDF dimension sizes

*.

*  Set an initial null value for the first returned pointer.
      IP( 1 ) = IMG__NOPTR

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Assign the NDF dimension.
      DIM( 1 ) = NX

*  Create temporary NDF(s).
      CALL IMG1_TPNDF( PARAM, '_REAL', NDIM, DIM, IP, STATUS )

*  If an error occurred, then report a contextual message.
      IF ( STATUS .NE. SAI__OK ) THEN
         IF ( INDEX( PARAM, ',' ) .NE. 0 ) THEN 
            CALL ERR_REP( 'IMG_TMP1_ERR',
     :           'IMG_TMP1: Error creating temporary ' //
     :           '1-dimensional images.', STATUS )
         ELSE
            CALL ERR_REP( 'IMG_TMP1_ERR',
     :           'IMG_TMP1: Error creating a temporary ' //
     :           '1-dimensional image.', STATUS )
         END IF
      END IF

      END
* $Id$
