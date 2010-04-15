*+  P4_WRITE_NB - Write the contents of the P4_NB noticeboard from common block
      SUBROUTINE P4_WRITE_NB( PORT, STATUS )
*    Description :
*     This routine defines the contents of the P4_NB noticeboard.
*    Invocation :
*     CALL P4_WRITE_NB( PORT, STATUS )
*    Authors :
*     P N Daly   (JACH.HAWAII.EDU::PND)
*    History :
*      4-Aug-1994: Original version (PND)
*    endhistory
*    Type Definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'PRM_PAR'
*    Import :
      INTEGER PORT
*    Status :
      INTEGER STATUS             ! Global status
*    External functions :
      INTEGER CHR_LEN            ! Finds used length of string
*    Global variables :
      INCLUDE 'P4COM.INC'        ! P4 common block
*    Local variables :
      INTEGER NSTART, NEND       ! Limits of Do-loop
      INTEGER CLEN, I            ! Length of string and counter
      CHARACTER*(NBS_FLEN) CDUMMY
*-

*   Check for error on entry.
      IF ( STATUS .NE. SAI__OK ) RETURN

*   If 0 <= PORT <= MAXPORT, update just that port
      IF ( PORT.GE.0 .AND. PORT.LE.MAXPORT ) THEN
        NSTART = PORT
        NEND   = PORT
*   Else update them all
      ELSE
        NSTART = 0
        NEND   = MAXPORT
      ENDIF

      IF ( VERBOSE ) THEN
        CALL MSG_OUT( ' ', 'Writing noticeboard from common block', STATUS )
      ENDIF

*   Fill the dummy character string with blanks
      CALL CHR_FILL( ' ', CDUMMY )

*   Read the parameters from the common block
      DO I = NSTART, NEND, 1

        CALL NBS_PUT_CVALUE( DEVICE_NAME_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DEVICE_XOPT_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DEVICE_YOPT_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DEVICE_LUT_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DISPLAY_DATA_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( TITLE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DISPLAY_TYPE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( DISPLAY_PLANE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( CONTOUR_TYPE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( OVERCOLOUR_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( COLOUR_STYLE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( FG_COLOUR_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( BG_COLOUR_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( CUT_DIRECTION_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )
        CALL NBS_PUT_CVALUE( LAST_TYPE_ID(I), 0, CDUMMY(1:LEN(CDUMMY)), STATUS )

        CLEN = CHR_LEN( DEVICE_NAME(I) )
        CALL NBS_PUT_CVALUE( DEVICE_NAME_ID(I), 0, DEVICE_NAME(I), STATUS )
        CLEN = CHR_LEN( DEVICE_XOPT(I) )
        CALL NBS_PUT_CVALUE( DEVICE_XOPT_ID(I), 0, DEVICE_XOPT(I), STATUS )
        CLEN = CHR_LEN( DEVICE_YOPT(I) )
        CALL NBS_PUT_CVALUE( DEVICE_YOPT_ID(I), 0, DEVICE_YOPT(I), STATUS )
        CLEN = CHR_LEN( DEVICE_LUT(I) )
        CALL NBS_PUT_CVALUE( DEVICE_LUT_ID(I), 0, DEVICE_LUT(I), STATUS )
        CLEN = CHR_LEN( DISPLAY_DATA(I) )
        CALL NBS_PUT_CVALUE( DISPLAY_DATA_ID(I), 0, DISPLAY_DATA(I), STATUS )
        CLEN = CHR_LEN( TITLE(I) )
        CALL NBS_PUT_CVALUE( TITLE_ID(I), 0, TITLE(I), STATUS )
        CLEN = CHR_LEN( DISPLAY_TYPE(I) )
        CALL NBS_PUT_CVALUE( DISPLAY_TYPE_ID(I), 0, DISPLAY_TYPE(I), STATUS )
        CLEN = CHR_LEN( DISPLAY_PLANE(I) )
        CALL NBS_PUT_CVALUE( DISPLAY_PLANE_ID(I), 0, DISPLAY_PLANE(I), STATUS )
        CLEN = CHR_LEN( CONTOUR_TYPE(I) )
        CALL NBS_PUT_CVALUE( CONTOUR_TYPE_ID(I), 0, CONTOUR_TYPE(I), STATUS )
        CLEN = CHR_LEN( OVERCOLOUR(I) )
        CALL NBS_PUT_CVALUE( OVERCOLOUR_ID(I), 0, OVERCOLOUR(I), STATUS )
        CLEN = CHR_LEN( COLOUR_STYLE(I) )
        CALL NBS_PUT_CVALUE( COLOUR_STYLE_ID(I), 0, COLOUR_STYLE(I), STATUS )
        CLEN = CHR_LEN( FG_COLOUR(I) )
        CALL NBS_PUT_CVALUE( FG_COLOUR_ID(I), 0, FG_COLOUR(I), STATUS )
        CLEN = CHR_LEN( BG_COLOUR(I) )
        CALL NBS_PUT_CVALUE( BG_COLOUR_ID(I), 0, BG_COLOUR(I), STATUS )
        CLEN = CHR_LEN( CUT_DIRECTION(I) )
        CALL NBS_PUT_CVALUE( CUT_DIRECTION_ID(I), 0, CUT_DIRECTION(I), STATUS )
        CLEN = CHR_LEN( LAST_TYPE(I) )
        CALL NBS_PUT_CVALUE( LAST_TYPE_ID(I), 0, LAST_TYPE(I), STATUS )

        CALL NBS_PUT_VALUE( PLOT_AXES_ID(I), 0, VAL__NBI, PLOT_AXES(I), STATUS )
        CALL NBS_PUT_VALUE( PLOT_ERRORS_ID(I), 0, VAL__NBI, PLOT_ERRORS(I), STATUS )
        CALL NBS_PUT_VALUE( PLOT_WHOLE_ID(I), 0, VAL__NBI, PLOT_WHOLE(I), STATUS )
        CALL NBS_PUT_VALUE( PRE_ERASE_PLOT_ID(I), 0, VAL__NBI, PRE_ERASE_PLOT(I), STATUS )
        CALL NBS_PUT_VALUE( AUTOSCALE_ID(I), 0, VAL__NBI, AUTOSCALE(I), STATUS )
        CALL NBS_PUT_VALUE( PORT_OK_ID(I), 0, VAL__NBI, PORT_OK(I), STATUS )
        CALL NBS_PUT_VALUE( PLOT_OK_ID(I), 0, VAL__NBI, PLOT_OK(I), STATUS )

        CALL NBS_PUT_VALUE( CONTOUR_LEVELS_ID(I), 0, VAL__NBI, CONTOUR_LEVELS(I), STATUS )
        CALL NBS_PUT_VALUE( HISTOGRAM_BINS_ID(I), 0, VAL__NBI, HISTOGRAM_BINS(I), STATUS )
        CALL NBS_PUT_VALUE( HISTOGRAM_XSTEP_ID(I), 0, VAL__NBI, HISTOGRAM_XSTEP(I), STATUS )
        CALL NBS_PUT_VALUE( HISTOGRAM_YSTEP_ID(I), 0, VAL__NBI, HISTOGRAM_YSTEP(I), STATUS )
        CALL NBS_PUT_VALUE( HIST_SMOOTH_ID(I), 0, VAL__NBI, HIST_SMOOTH(I), STATUS )
        CALL NBS_PUT_VALUE( TOOSMALL_ID(I), 0, VAL__NBI, TOOSMALL(I), STATUS )
        CALL NBS_PUT_VALUE( TOOLARGE_ID(I), 0, VAL__NBI, TOOLARGE(I), STATUS )
        CALL NBS_PUT_VALUE( ISTART_ID(I), 0, VAL__NBI, ISTART(I), STATUS )
        CALL NBS_PUT_VALUE( IEND_ID(I), 0, VAL__NBI, IEND(I), STATUS )
        CALL NBS_PUT_VALUE( JSTART_ID(I), 0, VAL__NBI, JSTART(I), STATUS )
        CALL NBS_PUT_VALUE( JEND_ID(I), 0, VAL__NBI, JEND(I), STATUS )

        CALL NBS_PUT_VALUE( VXSTART_ID(I), 0, VAL__NBR, VXSTART(I), STATUS )
        CALL NBS_PUT_VALUE( VXEND_ID(I), 0, VAL__NBR, VXEND(I), STATUS )
        CALL NBS_PUT_VALUE( VYSTART_ID(I), 0, VAL__NBR, VYSTART(I), STATUS )
        CALL NBS_PUT_VALUE( VYEND_ID(I), 0, VAL__NBR, VYEND(I), STATUS )
        CALL NBS_PUT_VALUE( AXSTART_ID(I), 0, VAL__NBR, AXSTART(I), STATUS )
        CALL NBS_PUT_VALUE( AXEND_ID(I), 0, VAL__NBR, AXEND(I), STATUS )
        CALL NBS_PUT_VALUE( AYSTART_ID(I), 0, VAL__NBR, AYSTART(I), STATUS )
        CALL NBS_PUT_VALUE( AYEND_ID(I), 0, VAL__NBR, AYEND(I), STATUS )
        CALL NBS_PUT_VALUE( XSTART_ID(I), 0, VAL__NBR, XSTART(I), STATUS )
        CALL NBS_PUT_VALUE( XEND_ID(I), 0, VAL__NBR, XEND(I), STATUS )
        CALL NBS_PUT_VALUE( YSTART_ID(I), 0, VAL__NBR, YSTART(I), STATUS )
        CALL NBS_PUT_VALUE( YEND_ID(I), 0, VAL__NBR, YEND(I), STATUS )
        CALL NBS_PUT_VALUE( MODE_ID(I), 0, VAL__NBR, MODE(I), STATUS )
        CALL NBS_PUT_VALUE( MEAN_ID(I), 0, VAL__NBR, MEAN(I), STATUS )
        CALL NBS_PUT_VALUE( SIGMA_ID(I), 0, VAL__NBR, SIGMA(I), STATUS )
        CALL NBS_PUT_VALUE( LOW_ID(I), 0, VAL__NBR, LOW(I), STATUS )
        CALL NBS_PUT_VALUE( HIGH_ID(I), 0, VAL__NBR, HIGH(I), STATUS )
        CALL NBS_PUT_VALUE( FMIN_ID(I), 0, VAL__NBR, FMIN(I), STATUS )
        CALL NBS_PUT_VALUE( FMAX_ID(I), 0, VAL__NBR, FMAX(I), STATUS )
        CALL NBS_PUT_VALUE( SLICE_START_ID(I), 0, VAL__NBR, SLICE_START(I), STATUS )
        CALL NBS_PUT_VALUE( SLICE_END_ID(I), 0, VAL__NBR, SLICE_END(I), STATUS )
        CALL NBS_PUT_VALUE( CHAR_HEIGHT_ID(I), 0, VAL__NBR, CHAR_HEIGHT(I), STATUS )
      ENDDO

      IF ( STATUS .NE. SAI__OK ) THEN
        STATUS = SAI__ERROR
        CALL ERR_REP( ' ', 'P4_WRITE_NB: '/
     :    /'Failed to restore noticeboard from common block', STATUS )
      ELSE
        IF ( VERBOSE ) THEN
          CALL MSG_OUT( ' ',
     :      'Written to noticeboard from common block OK', STATUS )
        ENDIF
      ENDIF

      END
