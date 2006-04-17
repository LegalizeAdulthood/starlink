      SUBROUTINE KPG1_CHE2D( NPTS, XMIN, XMAX, X, YMIN, YMAX, Y, XDEG,
     :                         YDEG, NCOEF, CC, NW, WORK, EVAL, STATUS )
*+
*  Name:
*     KPG1_CHE2X

*  Purpose:
*     Evaluates a 2-dimensional Chebyshev polynomial.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL KPG1_CHE2X( NPTS, XMIN, XMAX, X, YMIN, YMAX, Y, XDEG,
*                      YDEG, NCOEF, CC, NW, WORK, EVAL, STATUS )

*  Description:
*     This routine evaluates a two-dimensional Chebyshev polynomial for
*     one or more arguments.  It uses Clenshaw's recurrence
*     relationship twice.

*  Arguments:
*     XMIN = ? (Given)
*        The lower endpoint of the range of the fit along the first
*        dimension.  The Chebyshev series representation is in terms of
*        a normalised variable, evaluated as (2x - (XMAX + XMIN) ) /
*        (XMAX - XMIN), where x is the original variable.  XMIN must be
*        less than XMAX.
*     XMAX = ? (Given)
*        The upper endpoint of the range of the fit along the second
*        dimension.  See XMIN.
*     X( NPTS ) = ? (Given)
*        The co-ordinates along the first dimension for which the
*        Chebyshev polynomial is to be evaluated.
*     YMIN = ? (Given)
*        The lower endpoint of the range of the fit along the first
*        dimension.  The Chebyshev series representation is in terms of
*        a normalised variable, evaluated as (2y - (YMAX + YMIN) ) /
*        (YMAX - YMIN), where y is the original variable.  YMIN must be
*        less than YMAX.
*     YMAX = ? (Given)
*        The upper endpoint of the range of the fit along the second
*        dimension.  See YMIN.
*     Y = ? (Given)
*        The co-ordinate along the second dimension for which the
*        Chebyshev polynomial is to be evaluated.
*     XDEG = INTEGER (Given)
*        The degree of the polynomial along the first dimension.
*     YDEG = INTEGER (Given)
*        The degree of the polynomial along the second dimension.
*     MCOEF = INTEGER (Given)
*        The number of coefficients.  This must be at least the product
*        of (XDEG+1) * (YDEG+1).
*     CC( MCOEF ) = ? (Given)
*        The Chebyshev coefficients.  These should be the order such
*        that CCij is in CC( i*(YDEG+1)+j+1 ) for i=0,XDEG; j=0,YDEG.
*        In other words the opposite order to Fortran standard.
*     NW = INTEGER (Given)
*        The number of elements in the work array.  It must be at least
*        XDEG + 1.
*     WORK( NW ) = ? (Returned)
*        Workspace.
*     EVAL( NPTS ) = ? (Returned)
*        The evaluated polynomial for the supplied arguments.  Should an
*        argument lie beyond the range ([XMIN,XMAX], [YMIN,YMAX] the
*        bad value is returned in the corresponding element of EVAL.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  [optional_subroutine_items]...
*  Notes:
*     There is a routine for the real and double precision data types:
*     replace "x" in the routine name by R or D respectively.  The
*     XMIN, XMAX, X, YMIN, YMAX, Y, CC, WORK, and EVAL arguments
*     supplied to the routine must have the data type specified.

*  Copyright:
*     Copyright (C) 1996, 1997 Central Laboratory of the Research Councils.
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
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}

*  History:
*     1996 October 4 (MJC):
*        Original version.
*     1997 July 31 (MJC):
*        Corrected a couple of error messages and tests.  Made more
*        efficient for a constant (zero-order) fit.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'PRM_PAR'          ! VAL__ constants

*  Arguments Given:
      INTEGER NPTS
      DOUBLE PRECISION XMIN
      DOUBLE PRECISION XMAX
      DOUBLE PRECISION X( NPTS )
      DOUBLE PRECISION YMIN
      DOUBLE PRECISION YMAX
      DOUBLE PRECISION Y
      INTEGER XDEG
      INTEGER YDEG
      INTEGER NCOEF
      DOUBLE PRECISION CC( NCOEF )
      INTEGER NW

*  Arguments Returned:
      DOUBLE PRECISION WORK( NW )
      DOUBLE PRECISION EVAL( NPTS )

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      INTEGER IOFFCC             ! Index offset of Chebyshev coefficient
      DOUBLE PRECISION D                  ! Summation to current order
      DOUBLE PRECISION DP1                ! Summation to current order plus one
      DOUBLE PRECISION DP2                ! Summation to current order plus two
      INTEGER ECOEF              ! Expected number of Chebyshev
                                 ! coefficients
      INTEGER I                  ! Loop counter for summation over
                                 ! second axis
      INTEGER K                  ! Loop counter for co-ordinates
      INTEGER ORDER              ! Loop counter for polynomial order
      DOUBLE PRECISION XN2                ! Twice the normalised first-axis
                                 ! co-ordinate
      DOUBLE PRECISION XNORM              ! Normalised first-axis co-ordinate
      DOUBLE PRECISION XR                 ! First-axis co-ordinate range
      DOUBLE PRECISION YN2                ! Twice the normalised second-axis
                                 ! co-ordinate
      DOUBLE PRECISION YNORM              ! Normalised second-axis co-ordinate
      DOUBLE PRECISION YR                 ! Second-axis co-ordinate range

*.

*  Set the returned values to be bad.
      DO K = 1, NPTS
         EVAL( K ) = VAL__BADD
      END DO

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Validate the data limits.
      IF ( XMAX .LE. XMIN ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETD( 'MX', XMAX )
         CALL MSG_SETD( 'MN', XMIN )
         CALL ERR_REP( 'KPG1_CHE2x_RANGEX',
     :     'Scaling range for Chebyshev polynomial along first '/
     :     /'dimension has minimum (^MN) not less than the maximum '/
     :     /'(^MX).  Programming error.', STATUS )
         GOTO 999
      END IF

*  Validate the data limits.
      IF ( YMAX .LE. YMIN ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETD( 'MX', YMAX )
         CALL MSG_SETD( 'MN', YMIN )
         CALL ERR_REP( 'KPG1_CHE2x_RANGEY',
     :     'Scaling range for Chebyshev polynomial along second '/
     :     /'dimension has minimum (^MN) not less than the maximum '/
     :     /'(^MX).  Programming error.', STATUS )
         GOTO 999
      END IF

*  Validate the number of coefficients.
      IF ( NCOEF .LT. 1 ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETI( 'NC', NCOEF )
         CALL ERR_REP( 'KPG1_CHE2x_NCOEF',
     :     'Chebyshev polynomial has fewer than 1 term.  '/
     :     /'Programming error.', STATUS )
         GOTO 999
      END IF

*  Validate the orders.
      IF ( XDEG .LT. 0 .OR. YDEG .LT. 0 ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETI( 'XD', XDEG )
         CALL MSG_SETI( 'YD', YDEG )
         CALL ERR_REP( 'KPG1_CHE2x_ORDERS',
     :     'Both Chebyshev polynomial orders (^XD,^YD) are not '/
     :     /'positive.  Programming error.', STATUS )
         GOTO 999
      END IF

*  Check that the number of coefficients is not excessive.
      ECOEF = ( XDEG + 1 ) * ( YDEG + 1 )
      IF ( ECOEF .GT. NCOEF ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETI( 'EC', ECOEF )
         CALL ERR_REP( 'KPG1_CHE2x_NCOEF',
     :     'Chebyshev polynomial has fewer than the required ^EC'/
     :     /'terms.  Programming error.', STATUS )
         GOTO 999
      END IF

*  Test for an invalid Y co-ordinate.
      IF ( ( Y - YMAX ) * ( Y - YMIN ) .GT. 0.0D0 ) THEN
         STATUS = SAI__ERROR
         CALL MSG_SETD( 'MX', YMAX )
         CALL MSG_SETD( 'MN', YMIN )
         CALL MSG_SETD( 'Y', Y )
         CALL ERR_REP( 'KPG1_CHE2x_BADY',
     :     'Cannot evaluate a Chebyshev polynomial for a y '/
     :     /'co-ordinate at ^Y.  It is outside the range [^MX,^MN].  '/
     :     /'Programming error.', STATUS )
         GOTO 999
      END IF

*  Evaluate results.
*  =================

*  First deal with the trivial case for efficiency.
      IF ( NCOEF .EQ. 1 ) THEN

*  Assign the constant to each point.  Note the convention where the
*  first coefficient is halved.
         DO K = 1, NPTS
            EVAL( K ) = CC( 1 ) / 2.0D0
         END DO

*  Now tackle the general case.
      ELSE

*  Define two useful variables.
         XR = XMAX - XMIN
         YR = YMAX - YMIN

*  Normalise the variable to lie in the range -1 to +1.  This form of
*  the expression guarantees that the computed normalised value lies
*  no more than four times the machine precision from its true value.
         YNORM = ( ( Y - YMIN ) - ( YMAX - Y ) ) / YR

*  Initialise variable for recurrence relationship.
         YN2 = 2.0D0 * YNORM

*  Sum the coefficients times the second-axis Chebyshev polynomials.
*  =================================================================

*  Apply Clenshaw's recurrence relationship for efficiency.  For terms
*  greater than NCOEF the value is zero.  Note the
         DO I = 1, XDEG + 1
            IOFFCC = ( I - 1 ) * ( YDEG + 1 )
            DP2 = 0.0D0
            DP1 = 0.0D0
            IF ( YDEG .GE. 1 ) THEN
               DO ORDER = YDEG + 1, 2, -1
                  D = DP1
                  DP1 = YN2 * DP1 - DP2 + CC( IOFFCC + ORDER )
                  DP2 = D
               END DO
            END IF

*  The final iteration is different.  The constant term is half of the
*  coefficient in the Chebyshev series.
            WORK( I ) = DP1 * YNORM - DP2 + CC( IOFFCC + 1 ) / 2.0D0
         END DO

*  Loop for each point to be evaluated.
         DO K = 1, NPTS

*  Check that the x co-ordinate is in range.
            IF ( ( X( K ) - XMAX ) *
     :           ( X( K ) - XMIN ) .LE. 0.0D0 ) THEN

*  Normalise the variable to lie in the range -1 to +1.  This form of
*  the expression guarantees that the computed normalised value lies
*  no more than four times the machine precision from its true value.
               XNORM = ( ( X( K ) - XMIN ) - ( XMAX - X( K ) ) ) / XR

*  Sum the C(I)s times the first-axis Chebyshev polynomials.
*  =========================================================

*  Initialise variable for recurrence relationship.
               XN2 = 2.0D0 * XNORM

*  Apply Clenshaw's recurrence relationship for efficiency.  For terms
*  greater than NCOEF the value is zero.
               DP2 = 0.0D0
               DP1 = 0.0D0
               IF ( XDEG .GE. 1 ) THEN
                  DO ORDER = XDEG + 1, 2, -1
                     D = DP1
                     DP1 = XN2 * DP1 - DP2 + WORK( ORDER )
                     DP2 = D
                  END DO
               END IF

*  The final iteration is different.  The constant term is half of the
*  coefficient in the Chebyshev series.
               EVAL( K ) = DP1 * XNORM - DP2 + WORK( 1 ) / 2.0D0
            END IF
         END DO
      END IF

  999 CONTINUE

      END
