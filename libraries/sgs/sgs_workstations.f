      PROGRAM WKSTN
*+
*  Name:
*     WKSTN

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     sgs_workstations

*  Description:
*     Lists the names and descriptions of all the available SGS
*     workstations on FORTRAN unit 6 (usually the terminal).

*  Copyright:
*     Copyright (C) 1988 Science & Engineering Research Council. All
*     Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA
*     02111-1307, USA

*  Authors:
*     DLT: D. L. Terrett (Starlink)
*     {enter_new_authors_here}

*  History:
*     22-NOV-1988 (PTW/DLT):
*        Modified.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      IMPLICIT NONE

      CALL SGS_WLIST(6)

      END
