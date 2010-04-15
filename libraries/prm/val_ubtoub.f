      BYTE FUNCTION VAL_UBTOUB( BAD, ARG, STATUS )
*+
*  Name:
*     VAL_UBTOUB

*  Purpose:
*     Copy a UNSIGNED BYTE value.

*  Language:
*     Starlink Fortran

*  Invocation:
*     RESULT = VAL_UBTOUB( BAD, ARG, STATUS )

*  Description:
*     The routine copies a value of type UNSIGNED BYTE.  It forms part of the
*     set of type conversion routines, but in this instance the
*     argument and result types are both the same, so the argument
*     value is simply copied.

*  Arguments:
*     BAD = LOGICAL (Given)
*        Whether the argument value (ARG) may be "bad" (this argument
*        actually has no effect on the behaviour of this routine, but
*        is present to match the other type conversion routines).
*     ARG = BYTE (Given)
*        The UNSIGNED BYTE value to be copied.
*     STATUS = INTEGER (Given)
*        This should be set to SAI__OK on entry, otherwise the routine
*        returns immediately with the result VAL__BADUB.  This routine
*        cannot produce numerical errors, so the STATUS argument will
*        not be changed.

*  Returned Value:
*     VAL_UBTOUB = BYTE
*        Returns the copied UNSIGNED BYTE value.  The value VAL__BADUB will
*        be returned if STATUS is not SAI__OK on entry.

*  Copyright:
*     Copyright (C) 1988 Science & Engineering Research Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful,but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA
*     02111-1307, USA

*  Authors:
*     R.F. Warren-Smith (STARLINK)
*     {enter_new_authors_here}

*  History:
*     4-JUL-1988 (RFWS):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

      INCLUDE 'PRM_PAR'          ! PRM_ public constants


*  Arguments Given:
      LOGICAL BAD                ! Bad data flag
      BYTE ARG                 ! Value to be copied

*  Status:
      INTEGER STATUS             ! Error status

*.

*  Check status.  Return the function result VAL__BADUB if not OK.
      IF( STATUS .NE. SAI__OK ) THEN
         VAL_UBTOUB = VAL__BADUB

*  If OK, return the argument value.
      ELSE
         VAL_UBTOUB = ARG
      ENDIF

*  Exit routine.
      END
