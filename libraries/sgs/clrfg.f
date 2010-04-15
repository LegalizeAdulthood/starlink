      SUBROUTINE sgs_CLRFG (IFLAG)
*+
*  Name:
*     CLRFG

*  Purpose:
*     Set the clear screen flag (RAL GKS dependent).

*  Language:
*     Starlink Fortran 77

*  Description:
*     This function depends on an escape inserted to the RAL GKS by
*     Starlink.

*  Arguments:
*     IFLAG = INTEGER (Given)
*         Flag state 0 => clear screen open.  Any other
*         value => don't clear

*  Copyright:
*     Copyright (C) 1991 Science & Engineering Research Council. All
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
*     11-DEC-1991 (DLT):
*        Modified.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*  Written To Common:
*     NCLORQ    l    no clear on open requested flag

*-

      IMPLICIT NONE

      INTEGER IFLAG

      INCLUDE 'sgscom'



*  Set no clear open requested flag
      IF (IFLAG.EQ.0) THEN
         NCLORQ = .FALSE.
      ELSE
         NCLORQ = .TRUE.
      END IF

      END
