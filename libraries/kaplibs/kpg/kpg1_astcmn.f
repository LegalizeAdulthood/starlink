*+
*  Name:
*     KPG_ASTCMN

*  Purpose:
*     Define functional accessor/setter interface to KPG_AST common block

*  Language:
*     Starlink Fortran 77

*  Type of Module:
*     Subroutines

*  Description:
*     This file contains a set of functions that enable access to the
*     KPG_AST common block from outside of the KPG library. Routines
*     are only added on demand.

*  Implementation Details:
*     The following routines are available:
*       KPG1_SETASTLN( LN ) - Set the ASTLN integer
*       KPG1_SETASTGRP( GRP ) - Set the ASTGRP identifier
*       KPG1_SETASTGSP( CHAR ) - Set ASTGSP character
*       KPG1_SETASTDSB( DRDSB ) - Set DRWDSB flag
*       KPG1_SETASTFIT( FIT ) - Set FIT flag
*       KPG1_GETASTNPS()
*       KPG1_GETASTING()
*       KPG1_GETASTOUG()
*       KPG1_GETASTDSB() 
*       KPG1_GETASTFIT() 

*  Notes:
*     Since the routines are only 3 lines long, they are all in 
*     a single file with minimal comment wrapper. Types of the argument
*     for SET methods match the type in the common block.

*  Copyright:
*     Copyright (C) 2004 Central Laboratory of the Research Councils.
*     Copyright (C) 2005 Particle Physics & Engineering Research Council.
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
*     TIMJ: Tim Jenness (JAC, Hawaii)
*     DSB: David Berry (JAC, UCLan)
*     {enter_new_authors_here}

*  History:
*     1-OCT-2004 (TIMJ):
*        Original version. Add enough for NDFPACK:WCSSHOW
*     14-SEP-2005 (TIMJ):
*        Add 3 new get accessors
*     16-DEC-2005 (DSB):
*        Added DRWDSB.
*     16-DEC-2005 (DSB):
*        Added FIT (FileInTitle).
*     {enter_further_changes_here}

*-

      SUBROUTINE KPG1_SETASTFIT( FIT )
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'
      LOGICAL FIT

      ASTFIT = FIT
      END

      SUBROUTINE KPG1_SETASTDSB( DRDSB )
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'
      LOGICAL DRDSB

      DRWDSB = DRDSB
      END

      SUBROUTINE KPG1_SETASTLN( LN )
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'
      INTEGER LN

      ASTLN = LN
      END

      SUBROUTINE KPG1_SETASTGRP( IGRP )
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'
      INTEGER IGRP

      ASTGRP = IGRP
      END

      SUBROUTINE KPG1_SETASTGSP( GSP )
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'
      CHARACTER*(1) GSP

      ASTGSP = GSP
      END

      LOGICAL FUNCTION KPG1_GETASTDSB ()
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'

      KPG1_GETASTDSB = DRWDSB
      END

      LOGICAL FUNCTION KPG1_GETASTFIT ()
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'

      KPG1_GETASTFIT = ASTFIT
      END

      INTEGER FUNCTION KPG1_GETASTNPS ()
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'

      KPG1_GETASTNPS = ASTNPS
      END

      INTEGER FUNCTION KPG1_GETASTOUG ()
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'

      KPG1_GETASTOUG = ASTOUG
      END

      INTEGER FUNCTION KPG1_GETASTING ()
      IMPLICIT NONE
      INCLUDE 'DAT_PAR'
      INCLUDE 'KPG_AST'

      KPG1_GETASTING = ASTING
      END

