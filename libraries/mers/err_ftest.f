      PROGRAM ERR_TEST
*+
*  Name:
*     ERR_TEST

*  Purpose:
*     Test the installation of the ERR/MSG libraries.

*  Language:
*     Starlink Fortran 77

*  Description:
*     Test calls to the ERR/MSG libraries.

*  Copyright:
*     Copyright (C) 1993 Science & Engineering Research Council.
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
*     PCTR: P.C.T. Rees (STARLINK)
*     {enter_new_authors_here}

*  History:
*     29-SEP-1993 (PCTR):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Status:
      INTEGER STATUS             ! Global status

      INTEGER LEVEL

*.

*  Initialise status.
      STATUS = SAI__OK

*  Call MSG_OUT.
      CALL MSG_BELL( STATUS )
      CALL MSG_SETC( 'TOK', '(SETC)')
      CALL MSG_SETD( 'DTK', 0.0D0 )
      CALL MSG_SETR( 'RTK', 0.0 )
      CALL MSG_SETI( 'ITK', 0 )
      CALL MSG_SETL( 'LTK', .FALSE. )
      CALL ERR_SYSER( 'ERR', 32 )
      CALL MSG_OUT( ' ', 'MSG is installed and working. - ^TOK' /
     :/ ' ^DTK - ^RTK - ^ITK - ^LTK - ^ERR',
     :     STATUS )
      CALL MSG_SYNC( STATUS )

*  Call ERR_REP and ERR_FLUSH.
      CALL ERR_BEGIN( STATUS )
      STATUS = SAI__ERROR
      CALL ERR_MARK
      CALL ERR_FACER( 'ERR', STATUS )
      CALL ERR_REP( ' ', 'ERR is installed and working. - ^ERR',
     :     STATUS )
      CALL ERR_FLBEL( STATUS )
      CALL ERR_RLSE

      STATUS = SAI__ERROR
      CALL ERR_REP( ' ','Will annul this', STATUS )
      CALL ERR_ANNUL( STATUS )
      CALL ERR_END( STATUS )

      CALL ERR_LEVEL( LEVEL )

      END
