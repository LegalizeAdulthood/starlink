      LOGICAL FUNCTION IMG1_OK( STATUS )
*+
*  Name:
*     IMG1_OK

*  Purpose:
*     Test if a status value is OK.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     RESULT = IMG1_OK( STATUS )

*  Description:
*     This routine tests a status value to see if it represents either
*     the value SAI__OK (always OK) or one of the values returned by
*     the parameter system to indicate special action (currently
*     PAR__NULL and PAR__ABORT).

*  Arguments:
*     STATUS = INTEGER (Given)
*        Status value to be tested.

*  Returned Value:
*     IMG1_OK = LOGICAL
*        .TRUE. if the status is OK, otherwise .FALSE..

*  Copyright:
*     Copyright (C) 1993 Science & Engineering Research Council

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK, RAL)
*     {enter_new_authors_here}

*  History:
*     28-FEB-1992 (RFWS):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'PAR_ERR'          ! PAR_ error codes

*  Arguments Given:
      INTEGER STATUS

*.

*  Test if the status is OK.
      IMG1_OK = ( STATUS .EQ. SAI__OK ) .OR.
     :          ( STATUS .EQ. PAR__NULL ) .OR.
     :          ( STATUS .EQ. PAR__ABORT )

      END
* $Id$
