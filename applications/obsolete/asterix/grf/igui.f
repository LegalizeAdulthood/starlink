*+  IGUI - interface with GUI
      SUBROUTINE IGUI(STATUS)
*    Description :
*    Deficiencies :
*    Bugs :
*    Authors :
*        rjv@star.sr.bham.ac.uk
*    History :
*    Type definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'PAR_ERR'
      INCLUDE 'PRM_PAR'
*    Global variables :
      INCLUDE 'IMG_CMN'
*    Status :
      INTEGER STATUS
*    Function declarations :
*    Local constants :
*    Local variables :
      CHARACTER*132 ACTION,VALUE
      INTEGER ID,SID,ITEMID,GCBID
*    Version :
      CHARACTER*30 VERSION
      PARAMETER (VERSION = 'IGUI Version 1.8-0')
*-
      CALL USI_INIT()

      CALL MSG_PRNT(VERSION)

      CALL USI_GET0C('ACTION',ACTION,STATUS)
      CALL CHR_UCASE(ACTION)

      IF (ACTION.EQ.'INIT') THEN

        CALL USI_GET0C('VALUE',VALUE,STATUS)
        CALL CHR_UCASE(VALUE)

        IF (VALUE.EQ.'GCB') THEN

*  initialise GCB
          CALL GCB_RDDSCF(STATUS)

        ENDIF

      ELSEIF (ACTION.EQ.'CREATE') THEN

*  get the name of the noticeboard that will pass information to GUI
        CALL USI_GET0C('VALUE',VALUE,STATUS)

*  create noticeboard
        CALL IGUI_CRENB(VALUE,STATUS)

        I_GUI=(STATUS.EQ.SAI__OK)

      ELSEIF (ACTION.EQ.'DESTROY') THEN

*  destroy noticeboard
        CALL NBS_LOSE_NOTICEBOARD(I_NBID,'FORCE',STATUS)
        I_GUI=.FALSE.

*  update noticeboard with current GCB
      ELSEIF (ACTION.EQ.'UPDATE') THEN

        CALL NBS_FIND_ITEM(I_NBID,'GCB',GCBID,STATUS)
        CALL GCB_FILLSHADOW(GCBID,STATUS)

*  update noticeboard with current coord transformation
      ELSEIF (ACTION.EQ.'TRANSFORM') THEN

        CALL IGUI_TRANSFORM(STATUS)

*  force synchronisation of GCB
      ELSEIF (ACTION.EQ.'SYCHRO') THEN

        CALL USI_GET0C('VALUE',VALUE,STATUS)
        CALL CHR_UCASE(VALUE)
        IF (VALUE.EQ.'ONED') THEN
          CALL IMG_1DGCB(STATUS)
        ELSEIF (VALUE.EQ.'TWOD') THEN
          CALL IMG_2DGCB(STATUS)
        ENDIF

      ELSEIF (ACTION.EQ.'CACHE') THEN

        CALL USI_GET0C('VALUE',VALUE,STATUS)
        CALL CHR_UCASE(VALUE)
        IF (VALUE.EQ.'ONED') THEN
          CALL GCB_CACHE(I_CACHE_1D,STATUS)
        ELSEIF (VALUE.EQ.'TWOD') THEN
          CALL GCB_CACHE(I_CACHE,STATUS)
        ENDIF

      ENDIF

      CALL USI_CLOSE()

      END


*+  IGUI_CRENB - create noticeboard
      SUBROUTINE IGUI_CRENB(NAME,STATUS)
*    Description :
*    Deficiencies :
*    Bugs :
*    Authors :
*        rjv@star.sr.bham.ac.uk
*    History :
*    Type definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'PAR_ERR'
      INCLUDE 'PRM_PAR'
*    Import :
      CHARACTER*(*) NAME
*    Global variables :
      INCLUDE 'IMG_CMN'
*    Status :
      INTEGER STATUS
*    Function declarations :
*    Local constants :
      INTEGER NBSIZ
      PARAMETER (NBSIZ=65536)
*    Local variables :
      CHARACTER*8 CNAME
      INTEGER OLDSIZ
      INTEGER ID,SID,ITEMID
      INTEGER GCBID
      INTEGER I,J
*-
      IF (STATUS.EQ.SAI__OK) THEN

*  see if it exists already
        CALL NBS_FIND_NOTICEBOARD(NAME,ID,STATUS)
*  if it does destroy it and make a new one
        IF (STATUS.EQ.SAI__OK) THEN
          CALL NBS_LOSE_NOTICEBOARD(ID,'FORCE',STATUS)
        ELSE
          CALL ERR_ANNUL(STATUS)
        ENDIF

        CALL NBS_TUNE('MAX_DEFN_SIZE',NBSIZ,OLDSIZ,STATUS)
        CALL NBS_BEGIN_DEFINITION(ID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'FLAG','_INTEGER',0,VAL__NBI,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'OPTIONS','_CHAR',0,12,SID,STATUS)

*  current region and position
        CALL NBS_DEFINE_PRIMITIVE(ID,'REGION','_CHAR',0,12,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'REGXMIN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'REGXMAX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'REGYMIN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'REGYMAX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'PIXEL','_CHAR',0,10,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'X','_REAL',0,VAL__NBR,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'Y','_REAL',0,VAL__NBR,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'RA','_CHAR',0,12,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'DEC','_CHAR',0,12,SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'RA2000','_DOUBLE',0,VAL__NBD,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'DEC2000','_DOUBLE',0,VAL__NBD,
     :                                                    SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'RA1950','_DOUBLE',0,VAL__NBD,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'DEC1950','_DOUBLE',0,VAL__NBD,
     :                                                    SID,STATUS)
*  data min/max/mean
        CALL NBS_DEFINE_PRIMITIVE(ID,'MIN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'MAX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'MEAN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'MERR','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)

*  data quality
        CALL NBS_DEFINE_PRIMITIVE(ID,'NGOOD','_INTEGER',0,VAL__NBI,SID,
     :                                                          STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'NBAD','_INTEGER',0,VAL__NBI,SID,
     :                                                         STATUS)

*  axes min/max
        CALL NBS_DEFINE_PRIMITIVE(ID,'XMIN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'XMAX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'YMIN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'YMAX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'XP','_INTEGER',0,VAL__NBI,SID,
     :                                                         STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'YP','_INTEGER',0,VAL__NBI,SID,
     :                                                         STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'XPMAX','_INTEGER',0,VAL__NBI,SID,
     :                                                         STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'YPMAX','_INTEGER',0,VAL__NBI,SID,
     :                                                         STATUS)

*  conversion of world coords to degrees
        CALL NBS_DEFINE_PRIMITIVE(ID,'WTODEG','_REAL',0,VAL__NBR,SID,
     :                                                         STATUS)


*  background modeller
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_RMS','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MAXR','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MAXX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MAXY','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MINR','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MINX','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MINY','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_MEAN','_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)

*   Background modeller sources
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_NSRC','_INTEGER',0,VAL__NBI,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_SRCX','_REAL',0,VAL__NBR,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_SRCY','_REAL',0,VAL__NBR,
     :                                                   SID,STATUS)
        CALL NBS_DEFINE_PRIMITIVE(ID,'BG_SRCR','_REAL',0,VAL__NBR,
     :                                                   SID,STATUS)

*  colour table
        CNAME='DATA'
        DO I=1,9
          DO J=1,9
            WRITE(CNAME(5:5),'(I1)') I
            WRITE(CNAME(6:6),'(I1)') J
            CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_CHAR',0,8,SID,STATUS)
          ENDDO
        ENDDO

        DO I=1,9
          CNAME='RED'
          WRITE(CNAME(4:4),'(I1)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
          CNAME='GREEN'
          WRITE(CNAME(6:6),'(I1)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
          CNAME='BLUE'
          WRITE(CNAME(5:5),'(I1)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        ENDDO
        DO I=10,16
          CNAME='RED'
          WRITE(CNAME(4:5),'(I2)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
          CNAME='GREEN'
          WRITE(CNAME(6:7),'(I2)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
          CNAME='BLUE'
          WRITE(CNAME(5:6),'(I2)') I
          CALL NBS_DEFINE_PRIMITIVE(ID,CNAME,'_REAL',0,VAL__NBR,SID,
     :                                                       STATUS)
        ENDDO
        CALL NBS_DEFINE_PRIMITIVE(ID,'COLOUR','_INTEGER',0,VAL__NBI,
     :                                                    SID,STATUS)

*  create shadow of GCB
        CALL NBS_DEFINE_STRUCTURE(ID,'GCB','GCB',GCBID,STATUS)
        CALL GCB_CRESHADOW(GCBID,STATUS)

        CALL NBS_END_DEFINITION(NAME,'CREATE_NOTICEBOARD',STATUS)

*  initialise items that will be read or written first by GUI
        CALL NBS_FIND_NOTICEBOARD(NAME,I_NBID,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'FLAG',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'OPTIONS',ITEMID,STATUS)
        CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'REGION',ITEMID,STATUS)
        CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'PIXEL',ITEMID,STATUS)
        CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'X',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'Y',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'XP',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'YP',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'XPMAX',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'YPMAX',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'RA',ITEMID,STATUS)
        CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'DEC',ITEMID,STATUS)
        CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'MIN',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'MAX',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'MEAN',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'MERR',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,0.0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'NGOOD',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'NBAD',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'COLOUR',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBI,0,STATUS)
        CNAME='DATA'
        DO I=1,9
          DO J=1,9
            WRITE(CNAME(5:5),'(I1)') I
            WRITE(CNAME(6:6),'(I1)') J
            CALL NBS_FIND_ITEM(I_NBID,CNAME,ITEMID,STATUS)
            CALL NBS_PUT_CVALUE(ITEMID,0,' ',STATUS)
          ENDDO
        ENDDO

      ENDIF

      END




*+  IGUI_TRANSFORM
      SUBROUTINE IGUI_TRANSFORM(STATUS)
*    Description :
*    Deficiencies :
*    Bugs :
*    Authors :
*        rjv@star.sr.bham.ac.uk
*    History :
*    Type definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'PAR_ERR'
      INCLUDE 'PRM_PAR'
*    Import :
*    Global variables :
      INCLUDE 'IMG_CMN'
*    Status :
      INTEGER STATUS
*    Function declarations :
*    Local constants :
*    Local variables :
      INTEGER ITEMID
      REAL XMIN,XMAX,YMIN,YMAX
*-
      IF (STATUS.EQ.SAI__OK) THEN

        XMIN=I_XBASE-0.5*I_XSCALE
        XMAX=XMIN+REAL(I_NX)*I_XSCALE
        YMIN=I_YBASE-0.5*I_YSCALE
        YMAX=YMIN+REAL(I_NY)*I_YSCALE
        CALL NBS_FIND_ITEM(I_NBID,'XMIN',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,XMIN,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'XMAX',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,XMAX,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'YMIN',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,YMIN,STATUS)
        CALL NBS_FIND_ITEM(I_NBID,'YMAX',ITEMID,STATUS)
        CALL NBS_PUT_VALUE(ITEMID,0,VAL__NBR,YMAX,STATUS)

      ENDIF

      END
