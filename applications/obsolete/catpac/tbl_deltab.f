      SUBROUTINE TBL_DELTAB( TBDSCR, STATUS)

*  Type Definitions:
      IMPLICIT NONE

*  Global Constants:
      INCLUDE 'SAE_PAR'
      INCLUDE 'DAT_ERR'
      INCLUDE 'DAT_PAR'
      INCLUDE 'CMP_ERR'
      INCLUDE 'TBL_PAR'


      CHARACTER*(*)  TBDSCR
      INTEGER STATUS

      CHARACTER*(DAT__SZNAM) GROUP

      CALL HDS_ERASE( TBDSCR, STATUS)

      RETURN
      END
