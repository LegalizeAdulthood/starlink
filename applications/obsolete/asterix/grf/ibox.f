*+  IBOX - define rectangular section of image
      SUBROUTINE IBOX(STATUS)
*    Description :
*    Method :
*    Deficiencies :
*    Bugs :
*    Authors :
*    History :
*     8 Aug 90: V1.2-1 keyboard mode
*     1 Jul 93: V1.2-2 GTR used (RJV)
*    16 Feb 94: V1.2-3 IMG_GETBOX used (RJV)
*    20 Sep 94: V1.7-0 region mask incorporated (RJV)
*    Type Definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'DAT_PAR'
*    Import :
*    Import-Export :
*    Export :
*    Status :
      INTEGER STATUS
*    External references :
*    Local Constants :
*    Local variables :
      REAL XC,YC,DX,DY
*    Global Variables :
      INCLUDE 'IMG_CMN'
*    Version :
      CHARACTER*30 VERSION
      PARAMETER (VERSION='IBOX Version 2.2-0')
*-
      CALL USI_INIT()

      CALL MSG_PRNT(VERSION)


      IF (.NOT.I_OPEN) THEN
        CALL MSG_PRNT('AST_ERR: image processing system not active')
      ELSEIF (.NOT.I_DISP) THEN
        CALL MSG_PRNT('AST_ERR: no image currently displayed')
      ELSE

*  ensure transformations are correct
        CALL GTR_RESTORE(STATUS)

*  get box position
        CALL IMG_GETBOX('XCENT','YCENT','XWID','YWID',XC,YC,DX,DY,
     :                                                      STATUS)

*  set region mask
        CALL IMG_SETWHOLE(STATUS)
        CALL IMG_SETBOX(XC,YC,DX,DY,.FALSE.,STATUS)

*  store box parameters
        CALL IMG_STOREBOX(XC,YC,DX,DY,STATUS)

*  mark box
        CALL IMG_BOX(XC,YC,DX,DY,STATUS)

      ENDIF

      CALL USI_CLOSE()

      END


