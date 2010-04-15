      SUBROUTINE MAG_SET(TP, FILE, START, BLOCK, STATUS)
*+
*  Name:
*     MAG_SET

*  Purpose:
*     Set current tape file/block positions.

*  Language:
*     Starlink Fortran

*  Invocation:
*     CALL MAG_SET(TD, FILE, START, BLOCK, STATUS)

*  Description:
*     Supply the MAG library with the current tape position.

*  Arguments:
*     TD=INTEGER (Given)
*        A variable containing the tape descriptor.
*     FILE=INTEGER (Given)
*        Expression specifying the tape file number.   This can be
*        zero or negative if unknown.
*     START=LOGICAL (Given)
*        Expression specifying whether the block number is relative
*        to the start or end of the specified file.
*     BLOCK=INTEGER (Given)
*        Expression specifying the block number.
*        If START is TRUE then this is relative to the start of the
*        file;  otherwise it is relative to the end of the file.
*        It can be specified zero or negative if unknown.
*     STATUS=INTEGER (Given and Returned)
*        Variable holding the status value.
*        If this variable is not SAI__OK on input, then the routine
*        will return without action.
*        If the routine fails to complete, this variable will be set
*        to an appropriate error number.

*  Algorithm:
*     The supplied tape position is stored in the MAGIO Common Block.

*  Copyright:
*     Copyright (C) 1983, 1986, 1989, 1991, 1993 Science & Engineering Research Council.
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
*     Jack Giddings (UCL::JRG)
*     {enter_new_authors_here}

*  History:
*     05-APR-1983:  Original.  (UCL::JRG)
*      6-Nov-1986:  Shorten comment lines for DOMAN  (RAL::AJC)
*     24-Jan-1989:  Improve documentation  (RAL::AJC)
*     14-Nov-1991:  Changed to new-style prologue (RAL::KFH)
*           Replaced tabs in end-of-line comments (RAL::KFH)
*           Replaced fac_$name by fac1_name (RAL::KFH)
*           Inserted implicit none (RAL::KFH)
*    22-Jan-1993:  Change include file names
*           Convert code to uppercase using SPAG (RAL::BKM)
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type definition:
      IMPLICIT NONE

*  Global Constants:
      INCLUDE 'SAE_PAR'         ! Standard SAE constants
      INCLUDE 'MAG_SYS'         ! MAG Internal Constants

*  Arguments Given:
      INTEGER TP                ! tape descriptor
      INTEGER FILE              ! file number
      LOGICAL START             ! offset position
      INTEGER BLOCK             ! block number from offset
*    Status return :
      INTEGER STATUS            ! status return

*  Global Variables:
      INCLUDE 'MAGIO_CMN'       ! MAG library states

*  External References:
      EXTERNAL MAG1_BLK          ! Block data subprogram that
                                 ! initializes MAGINT
*  Local Variables:
      INTEGER TD                ! Physical tape descriptor

*.


      IF ( STATUS.EQ.SAI__OK ) THEN
         CALL MAG1_GETTD(TP, TD, STATUS)
         IF ( STATUS.EQ.SAI__OK ) THEN
            TFILE(TP) = MAX(FILE, 0)
            TSTART(TP) = START
            TBLOCK(TP) = MAX(BLOCK, 0)
         END IF
      END IF

      RETURN
      END
