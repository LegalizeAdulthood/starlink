      SUBROUTINE SPD_WZEB( FILENO, IN, NELM, VARXST,
     :   MSKDIM, MSKUSE, MASK, MSKELM,
     :   NCOMP, FITPAR, FITDIM,
     :   CONT, CFLAGS, PFLAGS, WFLAGS, CENTRE, PEAK, FWHM,
     :   CHISQR, COVAR, STATUS )
*+
*  Name:
*     SPD_WZEB

*  Purpose:
*     Report FITGAUSS results to screen or log file.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL SPD_WZEB( FILENO, IN, NELM, VARXST,
*        MSKDIM, MSKUSE, MASK, MSKELM,
*        NCOMP, FITPAR, FITDIM,
*        CONT, CFLAGS, PFLAGS, WFLAGS, CENTRE, PEAK, FWHM,
*        CHISQR, COVAR, STATUS )

*  Description:
*     Report current settings of FITGAUSS to screen or log file.
*     The covariance matrix is reported in
*     the form of a correlation matrix and of errors to the free
*     parameters:
*                               covar(i,j)
*        corr(i,j) = -------------------------------
*                     SQRT( covar(i,i) covar(j,j) )
*
*        sigma(i) = SQRT( covar(i,i) )         if VARXST
*
*        sigma(i) = SQRT( covar(i,i) ) * rms   if .NOT.VARXST

*  Arguments:
*     FILENO = INTEGER (Given)
*        File unit number. Give -1 to report to screen (via MSG_OUT).
*     IN = CHARACTER * ( * ) (Given)
*        The input file name.
*     NELM = INTEGER (Given)
*        The size of the spectrum before masking.
*     VARXST = LOGICAL (Given)
*        True if variance was used.
*     MSKDIM = INTEGER (Given)
*        Size of MASK array. Must be even.
*     MSKUSE = INTEGER (Given)
*        Number of valid mask intervals.
*     MASK( MSKDIM ) = REAL (Given)
*        The mask is put together from up to MSKDIM/2 intervals:
*           complex mask = [MASK(1);MASK(1+MSKDIM/2)]
*                        U [MASK(2);MASK(2+MSKDIM/2)]
*                        U ...
*                        U [MASK(MSKUSE);MASK(MSKUSE+MSKDIM/2)].
*     MSKELM = INTEGER (Given)
*        Number of x values that lie within the mask.
*     NCOMP = INTEGER (Given)
*        The value of NCOMP is the number of Gauss components.
*        If given as zero, no Gauss components will be reported.
*     FITPAR = INTEGER (Given)
*        Number of free parameters.
*     FITDIM = INTEGER (Given)
*        max( 1, FITPAR ). Used for size of arrays.
*     CONT = REAL (Given)
*        For Gauss fits indicates the level of the continuum.
*     CFLAGS( NCOMP ) = INTEGER (Given)
*        Centre fit flags.
*     PFLAGS( NCOMP ) = INTEGER (Given)
*        Peak fit flags.
*     WFLAGS( NCOMP ) = INTEGER (Given)
*        Width fit flags.
*     CENTRE( NCOMP ) = REAL (Given)
*        Centre position for each Gauss component.
*     PEAK( NCOMP ) = REAL (Given)
*        Peak height for each Gauss component.
*     FWHM( NCOMP ) = REAL (Given)
*        The full width at half maximum for each Gauss component.
*     CHISQR = REAL (Given)
*        This is either chi-squared (VARXST true), or the square of rms
*        multiplied by the degrees of freedom (VARXST false). Note that
*        the latter is actually just the sum of squared deviations of
*        data from fit.
*     COVAR( FITDIM, FITDIM ) = DOUBLE PRECISION (Given)
*        Covariance matrix in case of a Gauss fit. If the fit was by
*        minimising r.m.s. (i.e. VARXST is false), then the covariances
*        are actually this matrix times the square of r.m.s.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     hme: Horst Meyerdierks (UoE, Starlink)
*     {enter_new_authors_here}

*  History:
*     02 May 1991 (hme):
*        Original version (REPORT).
*     03 May 1991 (hme):
*        Rearrange MASK elements so that first MSKDIM/2 are interval
*        starts, second MSKDIM/2 are interval ends.
*        Report only used coefficients.
*     08 May 1991 (hme):
*        Use FWHM instead of sigma.
*     19 Jun 1991 (hme):
*        Get SIGMA from calling routine, but report FWHM.
*        Get covariance matrix from calling routine and report it
*        as parameter errors and correlation matrix.
*        Report line integral (and its error).
*     22 Jul 1991 (hme):
*        FITDIM. Report row coordinates.
*     30 Oct 1991 (hme):
*        Order of free parameters in SPFHSS had been changed. This makes
*        calculation of line integral errors difficult, set them 0 now.
*     01 Nov 1991 (hme):
*        Write also the covariance matrix.
*     20 Nov 1991 (hme):
*        Fix the case where more numbers are written than fit into the
*        message string. Calculate proper line integral variances.
*        Scrap the covariance matrix. Beautify file output.
*     15 Jul 1992 (hme):
*        Cut down to needs of new FITGAUSS, i.e. no polynomials any
*        more.
*     10 May 1994 (hme):
*        Modify interface: Re-arrange order of arguments, discard some,
*        get FWHM instead of sigma, get chi-squared instead of normalised
*        chi-squared. Rename from SPFREP to SPD_WZEB.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER FILENO
      CHARACTER * ( * ) IN
      INTEGER NELM
      LOGICAL VARXST
      INTEGER MSKDIM
      INTEGER MSKUSE
      REAL MASK( MSKDIM )
      INTEGER MSKELM
      INTEGER NCOMP
      INTEGER FITPAR
      INTEGER FITDIM
      REAL CONT
      INTEGER CFLAGS( NCOMP )
      INTEGER PFLAGS( NCOMP )
      INTEGER WFLAGS( NCOMP )
      REAL CENTRE( NCOMP )
      REAL PEAK(   NCOMP )
      REAL FWHM(   NCOMP )
      REAL CHISQR
      DOUBLE PRECISION COVAR( FITDIM, FITDIM )

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      INTEGER MXCOMP             ! Maximum no. of Gauss components
      PARAMETER ( MXCOMP = 6 )
      REAL RT8LN2                ! Square root of 8 ln(2)
      PARAMETER ( RT8LN2 = 2.354820 )
      REAL RT2PI                 ! Square root of 2 pi
      PARAMETER (  RT2PI = 2.506628 )

*  Local Variables:
      CHARACTER * ( 80 ) STRING  ! Message string
      INTEGER I, I1, I2          ! Counters for components
      INTEGER J, J1, J2          ! Counters for parameters
      REAL SIGMA(    MXCOMP )    ! Line dispersions
      REAL FLUX(     MXCOMP )    ! Line fluxes
      REAL VARIAN( 4*MXCOMP )    ! Variances of the parameters
      REAL VARSCL                ! CHISQR or 1.
      REAL COVPW                 ! Covariance between peak and sigma
      CHARACTER * ( 10 ) PARNAM( 3*MXCOMP ) ! Names of the free parameters
      CHARACTER * ( 10 ) SEARCH( 2 ) ! Names of parameters searched for

*.

*  Check inherited status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Check number of components.
      IF ( NCOMP .GT. MXCOMP ) THEN
         STATUS = SAI__ERROR
         CALL ERR_REP( 'SPD_WZEB_E01', 'FITGAUSS: Error reporting ' //
     :      'fit results: Cannot report on that many components.',
     :      STATUS )
         GO TO 500
      END IF

*  Formats: 1xx Logfile output.
*  Formats: 2xx Screen output.
*  Formats: x0x General.
 101  FORMAT ( /
     :   ' SPECDRE: FitGauss results (v. 2.0--).' )
 102  FORMAT ( ' Input NDF:  ', A )
 107  FORMAT ( ' Variances used:           ', L1 )
 108  FORMAT ( ' No. of data points:       ', I5 )
 201  FORMAT ( ' SPECDRE: FitGauss results (v. 2.0--).' )

*  Formats: x1x Mask.
 111  FORMAT ( ' No. of mask intervals:        ', I1 )
 112  FORMAT ( ' No. of valid data points: ', I5 )
 113  FORMAT ( ' Mask:' )
 114  FORMAT ( ' ', 2G15.7E2 )
 115  FORMAT ( ' Actual abscissa range:' )

*  Formats: x2x Gauss.
 121  FORMAT ( ' Accepted continuum:       ', G15.7E2 )
 122  FORMAT ( ' No. of Gauss components:      ', I1 )
 123  FORMAT ( ' Fit flags:')
 124  FORMAT ( ' #   centre    peak    FWHM' )
 125  FORMAT ( ' ', I1, 3I8 )
 126  FORMAT ( ' List of free parameters:' )
 127  FORMAT ( ' ', I2, ' ', A10 )
 128  FORMAT ( ' Gauss components:' )
 129  FORMAT ( ' #   centre position     (+-)',
     :   '      peak height         (+-)',
     :   '      full width half max.(+-)',
     :   '      line integral       (+-)' )
 229  FORMAT ( '  #   centre pos.    peak height ',
     :   '      FWHM       line integral' )

*  Formats: x3x Gauss.
 130  FORMAT ( ' ', I1, ' ', 8G15.7E2 )
 230  FORMAT ( '  ', I1, '  ', 4G15.7E2 )
 231  FORMAT ( ' +/- ', 4G15.7E2 )
 132  FORMAT ( ' Correlation between free parameters:' )
 133  FORMAT ( ' ', 18F6.2 )
 233  FORMAT ( ' ', 12F6.2 )
 234  FORMAT ( '    ', 6F6.2 )

*  Formats: x5x Chi-squared or rms.
 151  FORMAT ( ' Degrees of freedom:       ', I5 )
 152  FORMAT ( ' Chi-squared:              ', G15.7E2 )
 153  FORMAT ( ' rms:                      ', G15.7E2 )
 154  FORMAT ( ' rms is undefined.' )

*  Get FWHM from above, but use sigma internally.
      DO 12 I = 1, NCOMP
         SIGMA(I) = FWHM(I) / RT8LN2
 12   CONTINUE

*  This part only if there are Gaussians to be reported.
      IF ( NCOMP .GT. 0 ) THEN

*     In case of no errors available the covariance matrix as given has
*     to be multiplied by rms**2 to contain the variances as diagonal
*     elements and the covariances off the diagonal.
         IF ( VARXST ) THEN
            VARSCL = 1.
         ELSE
            VARSCL = CHISQR / FLOAT(MSKELM-FITPAR)
         END IF

*     J counts free parameters, I counts Gauss components. The relation
*     between the two is not simple because of fixed and tied
*     parameters.
         J = 0

*     Variance of I-th centre.
         DO 1 I = 1, NCOMP
            IF ( CFLAGS(I) .EQ. 0 ) THEN
               J = J+1
               VARIAN(4*I-3) = REAL(COVAR(J,J)) * VARSCL
               WRITE( PARNAM(J), '(''Centre #'',I1,'' '')' ) I
            ELSE IF ( CFLAGS(I) .EQ. I ) THEN
               VARIAN(4*I-3) = 0.
            ELSE
               VARIAN(4*I-3) = VARIAN(4*CFLAGS(I)-3)
            END IF
 1       CONTINUE

*     Variance of I-th peak.
         DO 2 I = 1, NCOMP
            IF ( PFLAGS(I) .EQ. 0 ) THEN
               J = J+1
               VARIAN(4*I-2) = REAL(COVAR(J,J)) * VARSCL
               WRITE( PARNAM(J), '(''  Peak #'',I1,'' '')' ) I
            ELSE IF ( PFLAGS(I) .EQ. I ) THEN
               VARIAN(4*I-2) = 0.
            ELSE
               VARIAN(4*I-2) = VARIAN(4*PFLAGS(I)-2)
     :            * ( PEAK(I) / PEAK(PFLAGS(I)) ) ** 2
            END IF
 2       CONTINUE

*     Variance of I-th dispersion.
         DO 3 I = 1, NCOMP
            IF ( WFLAGS(I) .EQ. 0 ) THEN
               J = J+1
               VARIAN(4*I-1) = REAL(COVAR(J,J)) * VARSCL
               WRITE( PARNAM(J), '(''  FWHM #'',I1,'' '')' ) I
            ELSE IF ( WFLAGS(I) .EQ. I ) THEN
               VARIAN(4*I-1) = 0.
            ELSE
               VARIAN(4*I-1) = VARIAN(4*WFLAGS(I)-1)
     :            * ( SIGMA(I) / SIGMA(WFLAGS(I)) ) ** 2
            END IF
 3       CONTINUE

*     Flux and flux variance of I-th component. Use error propagation
*     with covariances. Resolve ties properly.
         DO 5 I = 1, NCOMP

*        The flux is simple.
            FLUX(I) = RT2PI * PEAK(I) * SIGMA(I)

*        Calculate the variance of the flux. For this we need to know,
*        which components I1 and I2 peak and sigma are tied to, and
*        which free parameters J1 and J2 those are.
            I1 = PFLAGS(I)
            IF ( I1 .EQ. 0 ) I1 = I
            I2 = WFLAGS(I)
            IF ( I2 .EQ. 0 ) I2 = I

*        Now find which free parameters are involved. If one of the
*        parameters is fixed, J1 or J2 will remain 0, indicating that
*        the covariance of peak and sigma should be taken as 0.0.
            WRITE( SEARCH(1), '(''  Peak #'',I1,'' '')' ) I1
            WRITE( SEARCH(2), '(''  FWHM #'',I1,'' '')' ) I2
            J1 = 0
            J2 = 0
            DO 4 J = 1, FITPAR
               IF ( SEARCH(1) .EQ. PARNAM(J) ) J1 = J
               IF ( SEARCH(2) .EQ. PARNAM(J) ) J2 = J
 4          CONTINUE

*        Covariance of the two free parameters involved.
            IF ( J1 .EQ. 0 .OR. J2 .EQ. 0 ) THEN
               COVPW = 0.
            ELSE
               COVPW = COVAR(J1,J2) * VARSCL
            END IF

*        Flux variance.
            VARIAN(4*I) = FLUX(I) * FLUX(I)
     :         * ( VARIAN(4*I1-2) / PEAK(I1) ** 2
     :           + VARIAN(4*I2-1) / SIGMA(I2) ** 2
     :           + 2. * COVPW / PEAK(I1) / SIGMA(I2) )

*        The correlation can be so strongly negative, that the resulting
*        flux variance is negative.
*        Probably it cannot. The problem was really a bug which
*        overestimated COVPW by a factor 1/VARSCL (= rms**-2).
*        We leave the message in here, hoping to never see it again.
            IF ( VARIAN(4*I) .LT. 0. ) THEN
               VARIAN(4*I) = 0.
               CALL MSG_SETC(   'MESS',
     :            'FITGAUSS: Negative variance. Set to 0.' )
               CALL MSG_OUT ( 'FITGAUSS_NEGVAR', ' ', STATUS )
            END IF

 5       CONTINUE
      END IF

*  Logfile output. Do not mix *-formats with proper formats.
      IF ( FILENO .GE. 0 ) THEN

*     General: Title, files, coordinates.
         WRITE( FILENO, 101 )
         WRITE( FILENO, 102 )     IN(:MIN(LEN(IN), 115))

*     General: use of variance, total number of data points.
         WRITE ( FILENO, 107 ) VARXST
         WRITE ( FILENO, 108 ) NELM

*     Mask.
         WRITE( FILENO, 111 ) MSKUSE
         WRITE( FILENO, 112 ) MSKELM
         WRITE( FILENO, 113 )
         WRITE( FILENO, 114 )
     :      ( MASK(I), MASK(I+MSKDIM/2), I = 1, MSKUSE )

*     This part only if there are Gauss components to be reported.
         IF ( NCOMP .GT. 0 ) THEN

*        Continuum level, no. of comp's, flags.
            WRITE( FILENO, 121 ) CONT
            WRITE( FILENO, 122 ) NCOMP
            WRITE( FILENO, 123 )
            WRITE( FILENO, 124 )
            WRITE( FILENO, 125 )
     :         ( I, CFLAGS(I), PFLAGS(I), WFLAGS(I), I = 1, NCOMP )
            WRITE( FILENO, 126 )
            WRITE( FILENO, 127 ) ( J, PARNAM(J)(:10), J = 1, FITPAR )

*        Fit results.
            WRITE( FILENO, 128 )
            WRITE( FILENO, 129 )
            WRITE( FILENO, 130 )
     :         ( I, CENTRE(I),       SQRT(VARIAN(4*I-3)),
     :              PEAK(I),         SQRT(VARIAN(4*I-2)),
     :              SIGMA(I)*RT8LN2, SQRT(VARIAN(4*I-1))*RT8LN2,
     :              FLUX(I),         SQRT(VARIAN(4*I)),
     :           I = 1, NCOMP )

*        Correlation matrix if it exists.
            IF ( COVAR(1,1) .NE. 0D0 ) THEN
               WRITE( FILENO, 132 )
               DO 6 J2 = 1, FITPAR
                  WRITE( FILENO, 133 ) ( COVAR(J1,J2)
     :               / SQRT( COVAR(J1,J1) ) / SQRT( COVAR(J2,J2) ),
     :               J1 = 1, FITPAR )
 6             CONTINUE
            END IF

*        R.m.s. or chi squared.
            WRITE( FILENO, 151 ) MSKELM - FITPAR
            IF ( VARXST ) THEN
               WRITE( FILENO, 152 ) CHISQR
            ELSE IF ( MSKELM - FITPAR .GT. 0 ) THEN
               WRITE( FILENO, 153 ) SQRT(CHISQR/FLOAT(MSKELM-FITPAR))
            ELSE
               WRITE( FILENO, 154 )
            END IF
         END IF

*  Screen output.
      ELSE

*     General: Title, files.
         CALL MSG_SETC( 'MESS', ' ' )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         WRITE( STRING, 102 )     IN(:MIN(LEN(IN), 65))
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS' , STATUS )

*     General: use of variance, total number of data points.
         WRITE ( STRING, 107 ) VARXST
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         WRITE ( STRING, 108 ) NELM
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )

*     Mask.
         WRITE( STRING, 111 ) MSKUSE
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         WRITE( STRING, 112 ) MSKELM
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         WRITE( STRING, 113 )
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         DO 7 I = 1, MSKUSE
            WRITE( STRING, 114 ) MASK(I), MASK(I+MSKDIM/2)
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
 7       CONTINUE
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )

*     This part only if there are Gauss components to be reported.
         IF ( NCOMP .GT. 0 ) THEN

*        Continuum level, no. of comp's.
            WRITE( STRING, 121 ) CONT
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            WRITE( STRING, 122 ) NCOMP
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )

*        Flags.
            WRITE( STRING, 123 )
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            WRITE( STRING, 124 )
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            DO 8 I = 1, NCOMP
               WRITE( STRING, 125 ) I, CFLAGS(I), PFLAGS(I), WFLAGS(I)
               CALL MSG_SETC( 'MESS', STRING )
               CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
 8          CONTINUE
            WRITE( STRING, 126 )
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            DO 9 J = 1, FITPAR
               WRITE( STRING, 127 ) J, PARNAM(J)(:10)
               CALL MSG_SETC( 'MESS', STRING )
               CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
 9          CONTINUE

*        Fit results.
            WRITE( STRING, 128 )
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            WRITE( STRING, 229 )
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            DO 10 I = 1, NCOMP
               WRITE( STRING, 230 ) I, CENTRE(I), PEAK(I),
     :            SIGMA(I)*RT8LN2, FLUX(I)
               CALL MSG_SETC( 'MESS', STRING )
               CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
               WRITE( STRING, 231 ) SQRT(VARIAN(4*I-3)),
     :            SQRT(VARIAN(4*I-2)), SQRT(VARIAN(4*I-1))*RT8LN2,
     :            SQRT(VARIAN(4*I))
               CALL MSG_SETC( 'MESS', STRING )
               CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
 10         CONTINUE

*        Correlation matrix if it exists.
            IF ( COVAR(1,1) .NE. 0D0 ) THEN
               WRITE( STRING, 132 )
               CALL MSG_SETC( 'MESS', STRING )
               CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
               DO 11 J2 = 1, FITPAR
                  WRITE( STRING, 233 )    ( COVAR(J1,J2)
     :                  / SQRT( COVAR(J1,J1) ) / SQRT( COVAR(J2,J2) ),
     :                  J1 = 1, MIN(12,FITPAR) )
                  CALL MSG_SETC( 'MESS', STRING )
                  CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
                  IF ( FITPAR .GT. 12 ) THEN
                     WRITE( STRING, 234 ) ( COVAR(J1,J2)
     :                  / SQRT( COVAR(J1,J1) ) / SQRT( COVAR(J2,J2) ),
     :                  J1 = 13, FITPAR )
                     STRING = '   ' // STRING(:77)
                     CALL MSG_SETC( 'MESS', STRING )
                     CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
                  END IF
 11            CONTINUE
            END IF

*        R.m.s. or chi squared.
            WRITE( STRING, 151 ) MSKELM - FITPAR
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
            IF ( VARXST ) THEN
               WRITE( STRING, 152 ) CHISQR
            ELSE IF ( MSKELM - FITPAR .GT. 0 ) THEN
               WRITE( STRING, 153 ) SQRT(CHISQR/FLOAT(MSKELM-FITPAR))
            ELSE
               WRITE( STRING, 154 )
            END IF
            CALL MSG_SETC( 'MESS', STRING )
            CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
         END IF

*     Final blank line.
         STRING = ' '
         CALL MSG_SETC( 'MESS', STRING )
         CALL MSG_OUT ( 'FITGAUSS_REPORT', '^MESS', STATUS )
      END IF

*  Return.
 500  CONTINUE
      END
