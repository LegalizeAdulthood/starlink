      SUBROUTINE CCD1_SKYSR( FACT, N, DAT1, DAT2, IP, WT, STATUS )
*+
*  Name:
*     CCD1_SKYSR

*  Purpose:
*     Generate weighting factors for sky noise suppression.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL CCD1_SKYSR( FACT, N, DAT1, DAT2, IP, WT, STATUS )

*  Description:
*     The routine generates a set of weighting factors which may be
*     used (either directly or by multiplying into an existing set of
*     weights) to suppress "sky noise" when inter-comparing two data
*     arrays. More specifically, the routine aims to reduce the weight
*     used where the density of points per unit data range is high (as
*     in "sky" regions of astronomical images) to prevent this high
*     density of points from dominating the straight line fit used when
*     inter-comparing data.
*
*     The routine considers the histogram of the values in each data
*     array by addressing the array's values in sorted order.  Where
*     the local density of points in a histogram exceeds the threshold
*     value AVDEN/ABS(FACT) (AVDEN being the average density of points
*     in the histogram as a whole) the weighting factor is set so that
*     the effective number of points is reduced to this threshold value
*     (otherwise, a weighting factor of unity is used).  If two
*     (non-unit) weighting factors need to be applied to any data point
*     (one from each histogram), then the actual factor used is the
*     geometric mean of the two.

*  Arguments:
*     FACT = REAL (Given)
*        The sky noise suppression factor, which sets the density
*        threshold for histogram points at which weighting factors
*        below unity start to be applied. The absolute value is used.
*     N = INTEGER (Given)
*        Number of points to be used in each data array.
*     DAT1( * ) = ? (Given)
*        First data array.
*     DAT2( * ) = ? (Given)
*        Second data array.
*     IP( N ) = INTEGER (Given and Returned)
*        On entry, this array should contain a set of pointers
*        identifying which elements of the DAT1 and DAT2 data arrays
*        are to be considered. On exit, it will contain a set of
*        pointers which access the original elements of the DAT2 array
*        in ascending order.
*     WT( * ) = ? (Returned)
*        Array of sky noise suppression factors. These are stored in
*        the elements of WT which correspond with the DAT1 and DAT2
*        elements to which they apply.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     -  There is a routine for processing real and double precision
*     data; replace "x" in the routine name by R or D as appropriate.
*     The data types of the DAT1, DAT2 and WT arguments should match
*     the routine being used.
*     -  A FACT value of one is normally effective, but a value set by
*     the approximate ratio of sky pixels to useful object pixels may
*     often be better.

*  Copyright:
*     Copyright (C) 1992 Science & Engineering Research Council

*  Copyright:
*     Copyright (C) 1998 Central Laboratory of the Research Councils

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK, RAL)
*     {enter_new_authors_here}

*  History:
*     29-MAY-1992 (RFWS):
*        Original version.
*     27-JUL-1992 (RFWS):
*        Added status checks.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'PRM_PAR'          ! Primitive data constants

*  Arguments Given:
      REAL FACT
      INTEGER N
      REAL DAT1( * )
      REAL DAT2( * )
      INTEGER IP( N )

*  Arguments Given and Returned:
      REAL WT( * )

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      REAL INTVL               ! Fraction of inter-quartile range
      PARAMETER ( INTVL = 1.0 / 20.0 )
      INTEGER MINPTS             ! Minimum points in smoothing box
      PARAMETER ( MINPTS = 7 )

*  Local Variables:
      REAL AVDENS              ! Average/threshold density of points
      REAL D1                  ! Minimum data value in local range
      REAL D2                  ! Maximum data value in local range
      REAL DENS                ! Local density of histogram points
      REAL DW                  ! Minimum local data range
      REAL RANGE               ! Data range
      REAL TINY                ! Smallest value to be handled safely
      INTEGER I                  ! Loop counter for data points
      INTEGER I1                 ! Lower data point in local range
      INTEGER I2                 ! Upper data point in local range
      INTEGER IHALF              ! Half width of smoothing box
      INTEGER IQ1                ! Lower quartile rank
      INTEGER IQ2                ! Upper quartile rank

*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Permute the pointer array so that it refers to the DAT1 values in
*  ascending order.
      CALL CCD1_QSRTR( N, DAT1, IP, STATUS )
      IF ( STATUS .EQ. SAI__OK ) THEN

*  Determine the threshold density of points in the DAT1 histogram,
*  this being the average density divided by ABS(FACT).  Protect
*  against possible overflow or division by zero.
         AVDENS = N - 1
         RANGE = ( DAT1( IP( N ) ) - DAT1( IP( 1 ) ) ) * ABS( FACT )
         TINY = AVDENS / NUM__MAXR
         IF ( RANGE .GT. TINY ) THEN
            AVDENS = AVDENS / RANGE
         ELSE
            AVDENS = NUM__MAXR
         END IF

*  Find the approximate inter-quartile data range as an estimate of the
*  width of the histogram.
         IQ1 = 1 + NINT( 0.25 * REAL( N - 1 ) )
         IQ2 = 1 + NINT( 0.75 * REAL( N - 1 ) )
         DW = DAT1( IP( IQ2 ) ) - DAT1( IP( IQ1 ) )

*  Find a suitable fraction of this width to use as a minimum smoothing
*  box half-width expressed in data values.  Also find a separate
*  minimum half-width for the smoothing box expressed in number of data
*  values.
         DW = DW * INTVL
         IHALF = MINPTS / 2

*  Loop to determine sky suppression factors for each data point.
         I1 = 1
         I2 = 1
         DO 3 I = 1, N

*  Determine the minimum range of data over which to assess the local
*  density of histogram points.
            D1 = DAT1( IP( I ) ) - DW
            D2 = DAT1( IP( I ) ) + DW

*  Loop to find a lower limit to the local range which is at least
*  IHALF points below the current data point and also has a data value
*  at least as small as the lower minimum range limit.
 1          CONTINUE             ! Start of 'DO WHILE' loop
            IF ( ( I1 .LT. I - IHALF ) .AND.
     :           ( DAT1( IP( I1 + 1 ) ) .LE. D1 ) ) THEN
               I1 = I1 + 1
               GO TO 1
            END IF

*  Similarly loop to find an upper limit at least IHALF points above
*  the current data point which has a data value at least as large as
*  the maximum local range limit.
 2          CONTINUE             ! Start of 'DO WHILE' loop
            IF ( ( I2 .LT. N ) .AND.
     :           ( ( I2 .LT. I + IHALF ) .OR.
     :             ( DAT1( IP( I2 ) ) .LT. D2 ) ) ) THEN
               I2 = I2 + 1
               GO TO 2
            END IF

*  Evaluate the mean density of histogram points over this local range,
*  protecting against possible overflow.
            DENS = I2 - I1
            TINY = DENS / NUM__MAXR
            RANGE = DAT1( IP( I2 ) ) - DAT1( IP( I1 ) )
            IF ( RANGE. GT. TINY ) THEN
               DENS = DENS / RANGE
            ELSE
               DENS = NUM__MAXR
            END IF

*  If the local density is more than the threshold density of points,
*  then adjust the weight to reduce the effective local density of
*  points to the threshold value.
            IF ( DENS .GT. AVDENS ) THEN
               WT( IP( I ) ) = AVDENS / DENS
            ELSE
               WT( IP( I ) ) = 1.0
            END IF
 3       CONTINUE
      END IF

*  Repeat for the second data array.
*  ================================
*  Permute the pointer array so that it refers to the DAT2 values in
*  ascending order.
      CALL CCD1_QSRTR( N, DAT2, IP, STATUS )
      IF ( STATUS .EQ. SAI__OK ) THEN

*  Determine the threshold density of points in the DAT2 histogram,
*  this being the average density divided by ABS(FACT).  Protect
*  against possible overflow or division by zero.
         AVDENS = N - 1
         RANGE = ( DAT2( IP( N ) ) - DAT2( IP( 1 ) ) ) * ABS( FACT )
         TINY = AVDENS / NUM__MAXR
         IF ( RANGE .GT. TINY ) THEN
            AVDENS = AVDENS / RANGE
         ELSE
            AVDENS = NUM__MAXR
         END IF

*  Find the approximate inter-quartile data range as an estimate of the
*  width of the histogram.
         DW = DAT2( IP( IQ2 ) ) - DAT2( IP( IQ1 ) )

*  Find a suitable fraction of this width to use as a minimum smoothing
*  box half-width expressed in data values.
         DW = DW * INTVL

*  Loop to determine sky suppression factors for each data point.
         I1 = 1
         I2 = 1
         DO 6 I = 1, N

*  Determine the minimum range of data over which to assess the local
*  density of histogram points.
            D1 = DAT2( IP( I ) ) - DW
            D2 = DAT2( IP( I ) ) + DW

*  Loop to find a lower limit to the local range which is at least
*  IHALF points below the current data point and also has a data value
*  at least as small as the lower minimum range limit.
 4          CONTINUE             ! Start of 'DO WHILE' loop
            IF ( ( I1 .LT. I - IHALF ) .AND.
     :           ( DAT2( IP( I1 + 1 ) ) .LE. D1 ) ) THEN
               I1 = I1 + 1
               GO TO 4
            END IF

*  Similarly loop to find an upper limit at least IHALF points above
*  the current data point which has a data value at least as large as
*  the maximum local range limit.
 5          CONTINUE             ! Start of 'DO WHILE' loop
            IF ( ( I2 .LT. N ) .AND.
     :           ( ( I2 .LT. I + IHALF ) .OR.
     :             ( DAT2( IP( I2 ) ) .LT. D2 ) ) ) THEN
               I2 = I2 + 1
               GO TO 5
            END IF

*  Evaluate the mean density of histogram points over this local range,
*  protecting against possible overflow.
            DENS = I2 - I1
            TINY = DENS / NUM__MAXR
            RANGE = DAT2( IP( I2 ) ) - DAT2( IP( I1 ) )
            IF ( RANGE. GT. TINY ) THEN
               DENS = DENS / RANGE
            ELSE
               DENS = NUM__MAXR
            END IF

*  If the local density is more than the threshold density of points,
*  then adjust the weight to reduce the effective local density of
*  points to the threshold value.
            IF ( DENS .GT. AVDENS ) THEN
               WT( IP( I ) ) = SQRT( WT( IP( I ) ) * ( AVDENS / DENS ) )
            END IF
 6       CONTINUE
      END IF

      END
* @(#)ccg1_skys.grd	1.1     7/18/95     1
