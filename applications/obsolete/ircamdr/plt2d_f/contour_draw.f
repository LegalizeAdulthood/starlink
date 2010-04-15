	SUBROUTINE CONTOUR_DRAW( IMAGE,
     :	                         CONTOUR_ANNOTATE,
     :	                         CONTOUR_NUMBER,
     :	                         CONTOUR_AUTO,
     :	                         CONTOUR_BASE,
     :	                         CONTOUR_INTERVAL,
     :	                         CONTOUR_MAGNIF,
     :	                         CONTOUR_TITLE,
     :	                         STATUS)

* Subroutine to organize drawing of contour map and extras

* HISTORY
* 20-Jul-1994 Changed LIB$ calls to CHR_ and IFIX to INT (SKL$JACH)
* 26-Oct-1994 Changed MAGNIF from INT to REAL (SKL@JACH)
*

	IMPLICIT NONE

	INCLUDE 'ADAM_DEFNS'
        INCLUDE 'SAE_PAR'
	INCLUDE 'DTDEFNS'
	INCLUDE 'DTERRS'
        INCLUDE 'CHR_ERR'
	INCLUDE 'PLT2DCOM'

	INTEGER COLOUR_NUMBER
	REAL CONTOUR_MAGNIF
	INTEGER CONTOUR_NUMBER
	INTEGER CONTOUR_NUMBER2
	INTEGER CONTOUR_NUMBER3
	INTEGER J
	INTEGER LEN1
	INTEGER POSLAST
	INTEGER POS
	INTEGER ST
	INTEGER STATUS
	INTEGER TEMP_XCEN
	INTEGER TEMP_YCEN
	INTEGER TICKSPA
	INTEGER PEN_ANN
	INTEGER PEN_AXE
	INTEGER PEN_NUM
	INTEGER PEN_TIC
	INTEGER PEN_CON
	INTEGER PEN_CON1
	INTEGER PEN_CON2

	REAL CONTOUR_AXRAT
	REAL CONTOUR_BASE
	REAL CONTOUR_INTERVAL
	REAL CONTOUR_LEVEL( 50)
	REAL CONTOUR_XOFF
	REAL CONTOUR_YOFF
	REAL CONTOUR_SPLIT
	REAL DIVISOR
	REAL IMAGE( NX, NY)
	REAL IMXCEN
	REAL IMYCEN
	REAL SINGCON_BASE
	REAL TICK_XINTERVAL
	REAL TICK_YINTERVAL
	REAL XMAXIMUM
	REAL XMINIMUM

	CHARACTER*1 COL_ANN
	CHARACTER*1 COL_AXE
	CHARACTER*1 COL_NUM
	CHARACTER*1 COL_TIC
	CHARACTER*1 COL_CON
	CHARACTER*1 COL_CON1
	CHARACTER*1 COL_CON2
	CHARACTER*132 CONLEVEL_STRING
	CHARACTER*1 CONTOUR_COLTYPE
	CHARACTER*1 CONTOUR_TYPE
	CHARACTER*(*) CONTOUR_AUTO
	CHARACTER*20 CONTOUR_POSITIONING
	CHARACTER*(*) CONTOUR_TITLE
	CHARACTER*(*) CONTOUR_ANNOTATE
	CHARACTER*20 CURSOR_WHERE

	LOGICAL MORE

* ===========================================================================

* get colour for axes from parameter system
	IF( DEVICE_NAME .EQ. 'T5688' .OR.
     :	    DEVICE_NAME .EQ. 'ARGS'  .OR.
     :	    DEVICE_NAME .EQ. 'ARGS_OVERLAY' .OR.
     :	    DEVICE_NAME .EQ. 'T6134' .OR.
     :	    DEVICE_NAME .EQ. 'IKON'  .OR.
     :	    DEVICE_NAME .EQ. 'IKON_OVERLAY' .OR.
     :	    DEVICE_NAME .EQ. 'CPSP' .OR.
     :	    DEVICE_NAME .EQ. 'CPSL' .OR.
     :	    DEVICE_NAME .EQ. 'X-WINDOWS' .OR.
     :	    DEVICE_NAME .EQ. 'VAXSTATION8') THEN
	  CALL PAR_GET0C( 'CONTOUR_COLTYPE', CONTOUR_COLTYPE, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLANN', COL_ANN, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLAXE', COL_AXE, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLNUM', COL_NUM, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLTIC', COL_TIC, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLCON', COL_CON, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLCON1', COL_CON1, STATUS)
	  CALL PAR_GET0C( 'CONTOUR_COLCON2', COL_CON2, STATUS)
	ELSE
	  COL_ANN = 'N'
	  COL_AXE = 'N'
	  COL_NUM = 'N'
	  COL_TIC = 'N'
	  COL_CON = 'N'
	  COL_CON1 = 'N'
	  COL_CON2 = 'N'

!	  COL_ANN = 'W'
!	  COL_AXE = 'W'
!	  COL_NUM = 'W'
!	  COL_TIC = 'W'
!	  COL_CON = 'W'
!	  COL_CON1 = 'W'
!	  COL_CON2 = 'N'
	END IF

* get the pen number for the contour map annotation
	CALL PAR_GET0I( 'CONTOUR_PENANN', PEN_ANN, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENAXE', PEN_AXE, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENNUM', PEN_NUM, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENTIC', PEN_TIC, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENCON', PEN_CON, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENCON1', PEN_CON1, STATUS)
	CALL PAR_GET0I( 'CONTOUR_PENCON2', PEN_CON2, STATUS)

* test if want to auto contour and calculate the auto base,step
	IF( CONTOUR_AUTO .EQ. 'AUTO') THEN

* calculate the maximum and minimum in the image
	  CALL CALCULATE_MAXMIN( IMAGE, XMAXIMUM, XMINIMUM)
	  CONTOUR_BASE = XMINIMUM
	  CONTOUR_INTERVAL = ( XMAXIMUM - XMINIMUM)/CONTOUR_NUMBER
	END IF

* get the contour axis ratio for plot
	CALL PAR_GET0R( 'CONTOUR_AXRAT', CONTOUR_AXRAT, STATUS)

* get the positioning selection from the parameter system
	CALL PAR_GET0C( 'CONTOUR_POSN', CONTOUR_POSITIONING,
     :	                STATUS)
	CALL PAR_GET0C( 'CURSOR_WHERE', CURSOR_WHERE, STATUS)

* test the users choice
	IF( CONTOUR_POSITIONING .EQ. 'CURSOR') THEN

* get the cursor position
	  CALL CURSOR_POSITION( STATUS)
	  CALL PAR_GET0R( 'X_CUR_REAL', IMXCEN, STATUS)
	  CALL PAR_GET0R( 'Y_CUR_REAL', IMYCEN, STATUS)

* calculate start and end of contour box
	  IF( CURSOR_WHERE .EQ. 'BOTTOM_LEFT') THEN
	    IM_XST = IMXCEN
	    IM_YST = IMYCEN
	    IM_XEN = IM_XST + NX*CONTOUR_MAGNIF
	    IM_YEN = IM_YST + NY*CONTOUR_MAGNIF*CONTOUR_AXRAT
	  ELSE IF( CURSOR_WHERE .EQ. 'TOP_RIGHT') THEN
	    IM_XST = IMXCEN - NX*CONTOUR_MAGNIF
	    IM_YST = IMYCEN - NY*CONTOUR_MAGNIF*CONTOUR_AXRAT
	    IM_XEN = IM_XST + NX*CONTOUR_MAGNIF
	    IM_YEN = IM_YST + NY*CONTOUR_MAGNIF*CONTOUR_AXRAT
	  ELSE
	    IM_XST = IMXCEN - NX*CONTOUR_MAGNIF/2.0
	    IM_YST = IMYCEN - NY*CONTOUR_MAGNIF*CONTOUR_AXRAT/2.0
	    IM_XEN = IM_XST + NX*CONTOUR_MAGNIF
	    IM_YEN = IM_YST + NY*CONTOUR_MAGNIF*CONTOUR_AXRAT
	  END IF
	ELSE

* get the position of the centre of the contour map
	  CALL PAR_GET0I( 'CONTOUR_XCEN', TEMP_XCEN, STATUS)
	  CALL PAR_GET0I( 'CONTOUR_YCEN', TEMP_YCEN, STATUS)
	  IMXCEN = REAL( TEMP_XCEN)
	  IMYCEN = REAL( TEMP_YCEN)

* get the contour offsets for positioning
	  CALL PAR_GET0R( 'CONTOUR_XOFF', CONTOUR_XOFF, STATUS)
	  CALL PAR_GET0R( 'CONTOUR_YOFF', CONTOUR_YOFF, STATUS)

* calculate start and end of contour box
	  IM_XST = IMXCEN - ( NX+CONTOUR_XOFF)*CONTOUR_MAGNIF/2.0
	  IM_YST = IMYCEN -
     :	             ( NY+CONTOUR_YOFF)*
     :                 CONTOUR_MAGNIF*CONTOUR_AXRAT/2.0
	  IM_XEN = IM_XST + NX*CONTOUR_MAGNIF
	  IM_YEN = IM_YST + ( NY*CONTOUR_MAGNIF)*CONTOUR_AXRAT
	END IF

* write x,y start,end to parameter system
	CALL PAR_PUT0R( 'IM_XEN', IM_XEN, STATUS)
	CALL PAR_PUT0R( 'IM_YST', IM_YST, STATUS)
	CALL PAR_PUT0R( 'IM_YEN', IM_YEN, STATUS)

* set colour of AXES
!	type *, 'axes pen,col = ', pen_axe, col_axe
!	CALL SET_COLOUR2( PEN_AXE, COL_AXE)

* plot box around plot
	IF( CONTOUR_ANNOTATE .NE. 'NO_ANNOTATION') THEN
	  CALL SGS_BOX( IM_XST, IM_XEN, IM_YST, IM_YEN)

* set colour of TICKS
!	type *, 'ticks pen,col = ', pen_tic, col_tic
	  CALL SET_COLOUR( PEN_TIC, COL_TIC)

* draw tick marks on plot
	  CALL PAR_GET0R( 'CONTOUR_TICKINT', TICK_XINTERVAL, STATUS)
	  CALL PAR_GET0R( 'CONTOUR_YTICKIN', TICK_YINTERVAL, STATUS)
	  CALL PAR_GET0I( 'CONTOUR_TICKSPA', TICKSPA, STATUS)
	  CALL CONTOUR_TICKS( TICK_XINTERVAL, TICK_YINTERVAL,
     :	                      CONTOUR_MAGNIF, CONTOUR_AXRAT, STATUS)

* put in the intermediate tick marks as requested
	  DIVISOR = 1.5
	  DO J = 1, TICKSPA
	    CALL CONTOUR_TICKSEC( DIVISOR,  TICK_XINTERVAL/(2**J),
     :	                          TICK_YINTERVAL/(2**J),
     :	                          CONTOUR_MAGNIF, CONTOUR_AXRAT,
     :                            STATUS)
	  END DO

* set colour of NUMBERS
!	type *, 'number pen,col = ', pen_num, col_num
	  CALL SET_COLOUR( PEN_NUM, COL_NUM)

* draw NUMBERS on plot
	  CALL CONTOUR_NUMBERS( TICK_XINTERVAL, TICK_YINTERVAL,
     :	                        CONTOUR_MAGNIF, CONTOUR_AXRAT, STATUS)

* set colour of ANNOTATION
!	type *, 'annot pen,col = ', pen_ann, col_ann
	  CALL SET_COLOUR( PEN_ANN, COL_ANN)

* call subroutine to plot annotation on contour plot
	  CALL CONTOUR_ANNOT( CONTOUR_NUMBER,
     :	                      CONTOUR_BASE,
     :	                      CONTOUR_INTERVAL,
     :	                      CONTOUR_TITLE,
     :	                      CONTOUR_MAGNIF,
     :	                      STATUS)
	END IF

* get contour type from parameter system
	CALL PAR_GET0C( 'CONTOUR_TYPE', CONTOUR_TYPE, STATUS)

* if type is C then get contour levels
	IF( CONTOUR_TYPE .EQ. 'C') THEN
	  CONLEVEL_STRING = ' '
	  CALL PAR_GET0C( 'CONTOUR_LEVELS', CONLEVEL_STRING, STATUS)
          CALL CHR_CLEAN(CONLEVEL_STRING)
          LEN1 = 0
	  CALL CHR_APPND(CONLEVEL_STRING, CONLEVEL_STRING, LEN1)
	  MORE = .TRUE.
	  J = 0
	  ST = 1
	  POS = 0
	  POSLAST = 0
	  DO WHILE ( MORE .AND. POS .LE. LEN1)
	    POSLAST = POS
	    POS = INDEX( CONLEVEL_STRING( ST:LEN1), ',') + ST - 1
	    IF( POS-1 .GE. ST) THEN
	      J = J + 1
              CALL CHR_CTOR(CONLEVEL_STRING( ST:POS-1),
     :                      CONTOUR_LEVEL( J), STATUS )
	      IF( STATUS .NE. SAI__OK) THEN
                CALL ERR_REP('ERR','Contour draw error', STATUS)
                CALL ERR_FLUSH( STATUS )
                CALL ERR_ANNUL(STATUS)
	      END IF
	      ST = POS + 1
	      MORE = .TRUE.
	    ELSE
	      J = J + 1
              CALL CHR_CTOR( CONLEVEL_STRING( POSLAST+1:),
     :                       CONTOUR_LEVEL( J), STATUS )
	      MORE = .FALSE.
	    END IF
	  END DO

* set the number of contours found in input string
	  CONTOUR_NUMBER = J
	END IF

* test if want contour_1 or contour_2 or contour_3 plot
	IF( CONTOUR_TYPE .EQ. 'A' .OR. CONTOUR_TYPE .EQ. '1' .OR.
     :	    CONTOUR_TYPE .EQ. 'T' .OR. CONTOUR_TYPE .EQ. '4') THEN

	  IF( CONTOUR_TYPE .EQ. 'T' .OR. CONTOUR_TYPE .EQ. '4') THEN
	    CALL PAR_GET0R( 'CONTOUR_SPLIT', CONTOUR_SPLIT, STATUS)
	    CONTOUR_NUMBER2 =
     :	      INT( ( CONTOUR_SPLIT - CONTOUR_BASE)/CONTOUR_INTERVAL)
	    CONTOUR_NUMBER3 =
     :	      INT( ( ( CONTOUR_NUMBER*CONTOUR_INTERVAL+CONTOUR_BASE)-
     :	              CONTOUR_SPLIT)/CONTOUR_INTERVAL) + 1
	  END IF

* plot contour map 1
	  IF( CONTOUR_TYPE .EQ. 'T' .OR. CONTOUR_TYPE .EQ. '4') THEN
	    CALL SET_COLOUR( PEN_CON1, COL_CON1)
	    CALL CONTOUR_MAP( IMAGE, CONTOUR_BASE, CONTOUR_INTERVAL,
     :	                      CONTOUR_NUMBER2, CONTOUR_MAGNIF,
     :                        CONTOUR_AXRAT)
	    CALL SET_COLOUR( PEN_CON2, COL_CON2)
	    CALL CONTOUR_MAP( IMAGE, CONTOUR_SPLIT, CONTOUR_INTERVAL,
     :	                      CONTOUR_NUMBER3, CONTOUR_MAGNIF,
     :                        CONTOUR_AXRAT)
	  ELSE
!	type *, 'contour pen,col = ', pen_con, col_con
	    CALL SET_COLOUR( PEN_CON, COL_CON)
	    CALL CONTOUR_MAP( IMAGE, CONTOUR_BASE, CONTOUR_INTERVAL,
     :	                      CONTOUR_NUMBER, CONTOUR_MAGNIF,
     :                        CONTOUR_AXRAT)
	  END IF

	ELSE IF( CONTOUR_TYPE .EQ. 'S' .OR. CONTOUR_TYPE .EQ. '2')
     :      THEN

* plot contour map 2
	  SINGCON_BASE = 0.0
	  COLOUR_NUMBER = 0
	  DO J = 1, CONTOUR_NUMBER
	    IF( CONTOUR_COLTYPE .EQ. 'D') THEN
	      COLOUR_NUMBER = COLOUR_NUMBER + 1
	      IF( COLOUR_NUMBER .GT. 5) COLOUR_NUMBER = 1
	      IF( COLOUR_NUMBER .EQ. 1) COL_CON = 'W'
	      IF( COLOUR_NUMBER .EQ. 2) COL_CON = 'R'
	      IF( COLOUR_NUMBER .EQ. 3) COL_CON = 'G'
	      IF( COLOUR_NUMBER .EQ. 4) COL_CON = 'B'
	      IF( COLOUR_NUMBER .EQ. 5) COL_CON = 'Y'
	      IF( COLOUR_NUMBER .EQ. 1) PEN_CON = MAXIMCOL+11
	      IF( COLOUR_NUMBER .EQ. 2) PEN_CON = MAXIMCOL+12
	      IF( COLOUR_NUMBER .EQ. 3) PEN_CON = MAXIMCOL+13
	      IF( COLOUR_NUMBER .EQ. 4) PEN_CON = MAXIMCOL+14
	      IF( COLOUR_NUMBER .EQ. 5) PEN_CON = MAXIMCOL+15
	      CALL SET_COLOUR( PEN_CON, COL_CON)
	    ELSE
	      CALL SET_COLOUR( PEN_CON, COL_CON)
	    END IF
	    SINGCON_BASE = CONTOUR_BASE + CONTOUR_INTERVAL*(J-1)
	    CALL CONTOUR_MAP( IMAGE, SINGCON_BASE, CONTOUR_INTERVAL,
     :	                      1, CONTOUR_MAGNIF, CONTOUR_AXRAT)

* flush all output from graphics buffer to get all contour in same colour
	    CALL SGS_FLUSH
	  END DO

	ELSE IF( CONTOUR_TYPE .EQ. 'C' .OR. CONTOUR_TYPE .EQ. '3')
     :   THEN

* plot contour map 3
	  COLOUR_NUMBER = 0

* get the contour levels required
	  DO J = 1, CONTOUR_NUMBER
	    IF( CONTOUR_COLTYPE .EQ. 'D') THEN
	      COLOUR_NUMBER = COLOUR_NUMBER + 1
	      IF( COLOUR_NUMBER .GT. 5) COLOUR_NUMBER = 1
	      IF( COLOUR_NUMBER .EQ. 1) COL_CON = 'W'
	      IF( COLOUR_NUMBER .EQ. 2) COL_CON = 'R'
	      IF( COLOUR_NUMBER .EQ. 3) COL_CON = 'G'
	      IF( COLOUR_NUMBER .EQ. 4) COL_CON = 'B'
	      IF( COLOUR_NUMBER .EQ. 5) COL_CON = 'Y'
	      IF( COLOUR_NUMBER .EQ. 1) PEN_CON = MAXIMCOL+11
	      IF( COLOUR_NUMBER .EQ. 2) PEN_CON = MAXIMCOL+12
	      IF( COLOUR_NUMBER .EQ. 3) PEN_CON = MAXIMCOL+13
	      IF( COLOUR_NUMBER .EQ. 4) PEN_CON = MAXIMCOL+14
	      IF( COLOUR_NUMBER .EQ. 5) PEN_CON = MAXIMCOL+15
	      CALL SET_COLOUR( PEN_CON, COL_CON)
	    ELSE
	      CALL SET_COLOUR( PEN_CON, COL_CON)
	    END IF
	    CALL CONTOUR_MAP( IMAGE, CONTOUR_LEVEL( J),
     :	                      CONTOUR_INTERVAL, 1, CONTOUR_MAGNIF,
     :                        CONTOUR_AXRAT)

* flush all output from graphics buffer to get all contour in same colour
	    CALL SGS_FLUSH
	  END DO
	END IF
	CALL SGS_FLUSH

	END
