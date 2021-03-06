      SUBROUTINE KPS1_SUPEB( X, Y, Z, NBIN, XMIN, XMAX, YMIN, YMAX,
     :                       NXPAR, NYPAR, MCHOEF, CHCOEF, FIT,
     :                       RESID, RMS, STATUS )

*+
*  Name:
*     KPS1_SUPEB

*  Purpose:
*     Evaluates a bivariate Chebyshev polynomial series for a set of
*     x-y positions.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL KPS1_SUPEB( X, Y, Z, NBIN, XMIN, XMAX, YMIN, YMAX, NXPAR,
*                      NYPAR, MCHOEF, CHCOEF, FIT, RESID, RMS,
*                      STATUS )

*  Description:
*     This routine evaluates a bivariate Chebyshev polynomial at the
*     given vectors of x-y co-ordinates, and returns the fit and the
*     residuals. The rms difference between the fitted and the original
*     values is also calculated.

*  Arguments:
*     X( * ) = DOUBLE PRECISION (Given)
*        The x co-ordinates of the points to be evaluated.
*     Y( * ) = DOUBLE PRECISION (Given)
*        The y co-ordinates of the points to be evaluated.
*     Z( * ) = DOUBLE PRECISION (Given)
*        The values at the given x-y positions before fitting.
*     NBIN = INTEGER (Given)
*        The number of points at which the polynomial is to be
*        evaluated.
*     XMIN = DOUBLE PRECISION (Given)
*        Lower end of the x range of the fit. It must not be greater
*        than the x position of the first pixel in the data array.
*     YMIN = DOUBLE PRECISION (Given)
*        Lower end of the y range of the fit. It must not be greater
*        than the y position of the first pixel in the data array.
*     XMAX = DOUBLE PRECISION (Given)
*        Upper end of the x range of the fit. It must not be less
*        than the x position of the last pixel in the data array.
*     YMAX = DOUBLE PRECISION (Given)
*        Lower end of the y range of the fit. It must not be less
*        than the y position of the last pixel in the data array.
*     NXPAR = INTEGER (Given)
*        The number of parameters of the fit in the x direction, i.e
*        the degree of the polynomial plus one.
*     NYPAR = INTEGER (Given)
*        The number of parameters of the fit in the y direction, i.e
*        the degree of the polynomial plus one.
*     MCHOEF = INTEGER (Given)
*        The dimension of the array of Chebyshev coefficients.
*     CHCOEF( MCHOEF ) = DOUBLE PRECISION (Given)
*        The Chebyshev polynomial coefficients, in the order increasing
*        x power for each increasing y power.  Thus coefficient Aij in
*        the standard convention is %CHCOEF(i*(%NYPAR)+j+1). The array
*        may be rectangular, i.e. the highest x and y orders do not
*        have to be the same.
*     FIT( * ) = DOUBLE PRECISION (Returned)
*        The fitted array.
*     RESID( * ) = DOUBLE PRECISION (Returned)
*        The residuals of the fit.
*     RMS = REAL (Returned)
*        The rms difference between the raw array and the fitted array.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     -  Uses the magic-value method for bad or undefined pixels.

*  Algorithm:
*     -  Initialise the rms sums.
*     -  Scan through the pixels.
*     -  Evaluate the Chebyshev surface at the pixel.
*     -  Form residuals and sums for the rms error of the fit.
*     -  At the end of the loop calculate the rms error.

*  Copyright:
*     Copyright (C) 1990 Science & Engineering Research Council.
*     Copyright (C) 1996 Central Laboratory of the Research Councils.
*     Copyright (C) 2011 Science & Technology Facilities Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either Version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
*     02110-1301, USA.

*  Authors:
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}

*  History:
*     1990 January 30 (MJC):
*        Original version.
*     1996 October 8 (MJC):
*        Removed NAG.  Modern style.  Renamed from PLY2EB.
*     2011 May 11 (MJC):
*        Removed no-longer-used argument NCOEF.
*     {enter_further_changes_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'PRM_PAR'          ! Bad-pixel definitions

*  Arguments Given:
      DOUBLE PRECISION X( * )    ! X co-ordinates of the data
      DOUBLE PRECISION Y( * )    ! Y co-ordinates of the data
      DOUBLE PRECISION Z( * )    ! Data values
      INTEGER NBIN               ! Number of points for evaluation
      DOUBLE PRECISION XMIN, XMAX ! X bounds of the fit
      DOUBLE PRECISION YMIN, YMAX ! Y bounds of the fit
      INTEGER NXPAR              ! X degree of the polynomial plus 1
      INTEGER NYPAR              ! Y degree of the polynomial plus 1
      INTEGER MCHOEF             ! Dimension of Chebyshev coeff. array
      DOUBLE PRECISION CHCOEF( MCHOEF ) ! Chebyshev coefficients

*  Arguments Returned:
      DOUBLE PRECISION FIT( * )  ! Fitted data
      DOUBLE PRECISION RESID( * ) ! Residuals
      REAL RMS                   ! RMS difference between the fitted and
                                 ! unfitted arrays

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      INTEGER MXPAR              ! Maximum number of parameters which
                                 ! can be handled in each direction
      PARAMETER ( MXPAR = 15 )

*  Local Variables:
      INTEGER I                  ! Loop counter
      INTEGER NPT                ! Number of points used to calculate
                                 ! the rms
      DOUBLE PRECISION PX( MXPAR ) ! Work array
      REAL SUMSQ                 ! Sum of the square of differences

*.

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Initialise sums to form the rms error of the fit.
      SUMSQ = 0.0
      NPT = 0

*  Scan through the pixels.
      DO I = 1, NBIN

*  Evaluate the fitted surface at the pixel.
         CALL KPG1_CHE2D( 1, XMIN, XMAX, X( I ), YMIN, YMAX, Y( I ),
     :                    NXPAR - 1, NYPAR - 1, MCHOEF, CHCOEF, MXPAR,
     :                    PX, FIT( I ), STATUS )

*  Form residuals and sums for the rms error of the fit.
         IF ( Z( I ) .NE. VAL__BADD ) THEN
            RESID( I ) = FIT( I ) - Z( I )
            SUMSQ = SUMSQ + REAL ( RESID( I ) ** 2 )
            NPT = NPT + 1
         ELSE
            RESID( I ) = VAL__BADD
         END IF

*  End of the loop through the pixels.
      END DO

*  Calculate the rms error of the fit.
      IF ( NPT .GE. 1 ) THEN
         RMS = SQRT( SUMSQ / REAL( NPT ) )
      ELSE
         RMS = VAL__BADR
      END IF

      END
