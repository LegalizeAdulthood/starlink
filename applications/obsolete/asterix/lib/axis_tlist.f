*+ AXIS_TLIST - Lists the axes of the data array with their labels
      SUBROUTINE AXIS_TLIST( ID, NDIM, STATUS )
*    Description :
*       Lists the axes of the data array with their labels. First
*       checks if each axis is present.
*    Method :
*    Deficiencies :
*    Bugs :
*    Authors :
*      R.D.Saxton
*    History :
*      9 Aug 88 : Original (LTVAD::RDS)
*      7 Jun 89 : Renamed AXIS_LIST, some tidying (PLA)
*
*    Type Definitions :
*
      IMPLICIT NONE
*
*    Global constants :
*
      INCLUDE 'SAE_PAR'

*    Import :
      INTEGER			ID			! Dataset identifier
      INTEGER                	NDIM                  	! # axes in dataset

*    Status :
      INTEGER                	STATUS

*    Local variables :
      CHARACTER*40           LABEL                 ! Axis label

      INTEGER                I                     ! loop counter

      LOGICAL                OK                    ! Is object present ?
*-

*    Check status
      IF (STATUS .NE. SAI__OK) RETURN

      DO I = 1, NDIM
        CALL BDI_AXCHK( ID, I, 'Data', OK, STATUS )
        IF ( OK ) THEN
          CALL BDI_AXGET0C( ID, I, 'Label', LABEL, STATUS )
          CALL MSG_SETI ('I', I)
          CALL MSG_SETC( 'LABEL', LABEL )
          CALL MSG_PRNT( ' ^I ^LABEL' )
        ELSE
          CALL MSG_SETI ('I', I)
          CALL MSG_PRNT (' ^I WARNING: Axis information missing')
        END IF
      END DO

      IF ( STATUS .NE. SAI__OK ) THEN
        CALL AST_REXIT( 'AXIS_TLIST', STATUS )
      END IF

      END
