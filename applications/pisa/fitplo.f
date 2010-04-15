      SUBROUTINE FITPLO( ID0, ID1, ID2, RBUF, SBUF, YCURVE, RESIDS,
     :                   SIGMAS, RLIM, DLIM, CSIZE, NUSED, FITSIZ,
     :                   MINRES, MAXRES, RDOWN, RUP, DDOWN, DUP, MDOWN,
     :                   MUP, STATUS )
*+
*  Name:
*     FITPLO

*  Purpose:
*     To plot the profile data, its modelled fit, residuals and the
*     standard errors generated by PISAFIT.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL FITPLO( ID0, ID1, ID2, RBUF, SBUF, YCURVE, RESIDS, SIGMAS
*                  RLIM, DLIM, CSIZE, NUSED, FITSIZ, MINRES, MAXRES,
*                  RDOWN, RUP, DDOWN, DUP, MDOWN, MUP, STATUS )

*  Description:
*     The routine scales the upper and lower limits of all data plotted
*     to clearly show all data. It accesses the base AGI picture
*     and (identified by ID0, ID1 and ID2 are pictures within the
*     boundaries of this picture ) creates a viewport to cover it.
*     This viewport is then cleared of any previous information. The
*     routine then accesses two previously created AGI pictures
*     ( identified by ID1 and ID2 ), one to plot the profile data and
*     its fit, and one to plot the residuals between the data and its
*     fit. Labelled Boxes are drawn around each of these viewports. The
*     scaling limits are returned. The data actually used in the fit is
*     show as a different point type in the plot. The error bars are
*     drawn as plus/minus sigma about the residuals.

*  Arguments:
*     ID0 = INTEGER (Given)
*        The base viewport AGI picture identifier.
*     ID1 = INTEGER (Given)
*        The data viewport AGI picture identifier.
*     ID2 = INTEGER (Given)
*        The residuals viewport AGI picture identifier.
*     RBUF( FITSIZ )= REAL (Given)
*        Buffer containing the radii for which points have been derived.
*     SBUF( FITSIZ ) = REAL (Given)
*        Buffer containing the radial data points which are being
*        fitted.
*     YCURVE( FITSIZ ) = REAL (Given)
*        Buffer containing the model fit to data in SBUF.
*     RESIDS( FITSIZ ) = REAL (Given)
*        Buffer containing the residuals between the data and model.
*     SIGMAS = DOUBLE PRECISION (Given)
*        The standard error associated with each data point.
*     RLIM = REAL (Given)
*        Radius limit out to which data has been fitted.
*     DLIM = REAL (Given)
*        Intensity limit for data which has been fitted ( note that this
*        is always less then zero for log of intensity less <= 1 )
*     CSIZE = REAL (Given)
*        Size, as a fraction of normal PGPLOT character size, at which
*        labels etc. will be plotted.
*     NUSED = INTEGER (Given)
*        The actual number of the possible FITSIZ points used in the
*        fit.
*     FITSIZ = INTEGER (Given)
*        Size of the buffers contain data to be plotted.
*     MINRES = REAL (Given)
*        Minimum value of the residuals to be plotted.
*     MAXRES = REAL (Given)
*        Maximum value of the residuals to be plotted.
*     RDOWN = REAL (Returned)
*        The lower bound of the plotted radii ( not used, passed for
*        completeness ).
*     RUP = REAL (Returned)
*        The upper bound of the plotted radii.
*     DDOWN = REAL (Returned)
*        The lower bound of the plotted fit data ( intensity ).
*     DUP = REAL (Returned)
*        The upper bound of the plotted fit data ( intensity ).
*     MDOWN = REAL (Returned)
*        The lower bound of the plotted residuals.
*     MUP = REAL (Returned)
*        The lower bound of the plotted residuals.
*
*     STATUS = INTEGER (Given)
*        The global status.

*  Prior Requirements:
*     -  PGPLOT must be opened.

*  Authors:
*     PDRAPER: Peter Draper (STARLINK)
*     {enter_new_authors_here}

*  History:
*     24-SEP-1990 (PDRAPER):
*        Original version.
*     27-SEP-1990 (PDRAPER):
*        Added area clearing.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER ID0
      INTEGER ID1
      INTEGER ID2
      INTEGER NUSED
      INTEGER FITSIZ
      REAL RBUF( FITSIZ )
      REAL SBUF( FITSIZ )
      REAL YCURVE( FITSIZ )
      REAL RESIDS( FITSIZ )
      DOUBLE PRECISION SIGMAS( FITSIZ )
      REAL RLIM
      REAL DLIM
      REAL CSIZE
      REAL MINRES
      REAL MAXRES

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      REAL  ZERO                 ! real value of zero
      PARAMETER ( ZERO = 0.0 )
      INTEGER IZERO              ! integer value of zero
      PARAMETER ( IZERO = 0 )
      INTEGER PTYPE1             ! point plot type
      PARAMETER ( PTYPE1 = 13 )
      INTEGER PTYPE2             ! point plot type
      PARAMETER ( PTYPE2 = 7 )
      REAL OFFLIM                ! percentage to scale limits by to
                                 ! ensure that all data is seen clearly
      PARAMETER ( OFFLIM = 25.0 )

*  Local Variables:
      REAL RDOWN,RUP             ! plotting limits scaled to show all
                                 ! possible radii
      REAL DDOWN,DUP             ! plotting limits scaled to show all
                                 ! data points
      REAL MDOWN,MUP             ! plotting limits scaled to show all
                                 ! residuals
      REAL WX1, WX2, WY1, WY2    ! world coordinates of base picture
      INTEGER I                  ! loop counter
*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Select base viewport, create a viewport covering it.
      CALL AGI_SELP( ID0, STATUS )
      CALL AGP_NVIEW( .FALSE., STATUS)

*  Clear the base picture
      CALL AGI_IWOCO( WX1, WX2, WY1, WY2 , STATUS )
      CALL PGVCLR( WX1, WX2, WY1, WY2, STATUS )

*  Get the size of plot required
      CALL SCLLIM( OFFLIM, ZERO, RLIM, RDOWN, RUP, STATUS )
      CALL SCLLIM( OFFLIM, DLIM, ZERO, DDOWN, DUP, STATUS )

*  Select the picture to contain the data plot and create the new
*  viewport.
      CALL AGI_SELP( ID1, STATUS )
      CALL AGP_NVIEW( .FALSE., STATUS )

*  Set up the new world coordinates for this viewport
      CALL PGWINDOW( ZERO, RUP, DDOWN, ZERO )

*  Add the box and labels ( setting the character size )
      CALL PGSCH( CSIZE )
      CALL PGBOX( 'BCNST', ZERO, IZERO, 'BCNST', ZERO, IZERO )
      CALL PGLABEL( 'Radius (pixels)', 'Log10(Intensity)',
     :                ' ' )
      CALL PGMTEXT( 'T', 1.0, 0.5, 0.5, 'RADIAL PROFILE' )

* Plot the fitted data points
      CALL PGPOINT( NUSED, RBUF, SBUF, PTYPE1 )

* Plot the other fit data points
      IF ( FITSIZ .NE. NUSED ) THEN
        CALL PGPOINT( FITSIZ-NUSED, RBUF( NUSED + 1 ),
     :                SBUF( NUSED + 1 ), PTYPE2 )
      END IF

* Plot the model curve
      CALL PGLINE( FITSIZ, RBUF, YCURVE )

*  Plot the residuals.
*  Select the picture to contain the residuals plot and create the
*  new viewport.
      CALL AGI_SELP( ID2, STATUS )
      CALL AGP_NVIEW( .FALSE., STATUS )

*  Scale limits
      CALL SCLLIM( OFFLIM, MINRES, MAXRES, MDOWN, MUP, STATUS)

*  Set the world coordinates.
      CALL PGWINDOW( ZERO, RUP, MDOWN, MUP )

*  Plot the box, labels and data.
      CALL PGBOX( 'ABCST', ZERO, IZERO, 'BCNST', ZERO, IZERO )
      CALL PGLABEL( ' ', 'Log10(Intensity)',
     :                ' ' )
      CALL PGMTEXT( 'T', 1.0, 0.5, 0.5, 'RESIDUALS' )
      CALL PGPOINT( NUSED, RBUF, RESIDS, PTYPE1 )

* Plot the other model data points
      IF ( FITSIZ .NE. NUSED ) THEN
        CALL PGPOINT( FITSIZ-NUSED, RBUF( NUSED + 1 ),
     :                RESIDS( NUSED + 1 ), PTYPE2 )
      END IF

*  Add the error bars, only show non-zero ones
      DO 1 I = 1, FITSIZ
         IF( SIGMAS( I ) .GT. 0.0D0 ) THEN
             CALL PGERRY( 1, RBUF( I ),
     :                    REAL( RESIDS( I ) + SIGMAS( I ) ),
     :                    REAL( RESIDS( I ) - SIGMAS( I ) ), 1.0 )
         END IF
1     CONTINUE

      END
* $Id$
