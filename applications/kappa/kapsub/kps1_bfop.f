      SUBROUTINE KPS1_BFOP( RFRM, MAP, NAXR, NP, P, SIGMA, NBEAM,
     :                      REFOFF, POLAR, POLSIG, RMS, STATUS )
*+
*  Name:
*     KPS1_BFOP

*  Purpose:
*     Writes the fit coefficients and errors to output parameters.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL KPS1_BFOP( RFRM, MAP, NAXR, NP, P, SIGMA, NBEAM, REFOFF,
*                     POLAR, POLSIG, RMS, STATUS )

*  Description:
*     The supplied Gaussian parameters from BEAMFIT are written to the
*     environment.  Each output parameter is a two-element vector
*     containing the fit coefficient in the first element, and its error
*     in the second for the primary beam.
*
*     The parameters written are as follows.
*
*        CENTRE   LITERAL   The centre of the beam, formatted as a
*                           single string in the reference co-ordinate
*                           Frame
*        MAJFWHM  _DOUBLE   The major-axis full width half maximum
*                           in the reference co-ordinate Frame
*        MINFWHM  _DOUBLE   The minor-axis full width half maximum
*                           in the reference co-ordinate Frame
*        ORIENT   _DOUBLE   The orientation of the major axis in
*                           degrees
*        AMP      _DOUBLE   The amplitude of the Gaussian beam
*        BACK     _DOUBLE   The background level
*        RMS      _REAL     The RMS of the fit
*
*    In addition there is always a further vector parameter
*
*        REFOFF   LITERAL   The offset of the primary beam with respect
*                           to a reference position, and its error.
*
*    Two further parameters are written if the number of beam
*    positions is more than one.  Each is an array of length twice the
*    number of secondary beams, storing alternatinng value then error
*    for each secondary beam position, starting with the first and
*    progressing in order.
*
*        OFFSET   LITERAL   The radial offsets of the secondary beam
*                           positions from the primary beam, each
*                           formatted as a single single string in the
*                           reference co-ordinate Frame
*        PA      _REAL      The position angles of the secondary beam
*                           positions with respect to the primary beam.
*
*  Arguments:
*     RFRM = INTEGER (Given)
*        A pointer to the reporting Frame (i.e. the Frame in which
*        positions are to be reported).
*     MAP = INTEGER (Given)
*        The AST Mapping from the PIXEL Frame of the NDF to the
*        reporting Frame.
*     NAXR = INTEGER (Given)
*        The number of axes in the reporting Frame.
*     NP = INTEGER (Given)
*        The size of array P.
*     P( NP ) = DOUBLE PRECISION (Given)
*        The fit parameters.  Spatial co-ordinates should be measured
*        in the reporting Frame.  See KPS1_BFCRF to convert from
*        PIXEL co-ordinates.  Only the first BF_MXCOEF elements are
*        used.
*     SIGMA( NP ) = DOUBLE PRECISION (Given)
*        The errors in the fit parameters.   Spatial co-ordinates should
*        be measured in the reporting Frame.  Only the first BF_MXCOEF
*        elements are used.
*     NBEAM = INTEGER (Given)
*        The number of beam positions.
*     REFOFF( 2 ) = DOUBLE PRECISION (Given)
*        The offset of the primary beam with respect to the reference
*        point measured in the current WCS Frame, followed by its error.
*     POLAR( 2, NBEAM ) =  DOUBLE PRECISION (Given)
*         The polar co-ordinates of the beam features with respect to
*         the primary beam measured in the current co-ordinate Frame.
*         The orientation is a position angle in degrees, measured from
*         North through East if the current Frame is a Skyframe, or
*         anticlockwise from the Y axis otherwise.  The POLAR(*,1)
*         values of the primary beam are ignored.
*     POLSIG( 2, NBEAM ) =  DOUBLE PRECISION (Given)
*         The standard-deviation errors associated with the polar
*          co-ordinates supplied in argument POLAR.  The POLSIG(*,1)
*         values of the primary beam are ignored.
*     RMS = DOUBLE PRECISION (Given)
*        The RMS residual in pixels.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Copyright:
*     Copyright (C) 2007 Particle Physics & Astronomy Research Council.
*     Copyright (C) 2009 Science and Technology Facilities Council.
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
*     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
*     02111-1307, USA.

*  Authors:
*     MJC: Malcolm J. Currie (STARLINK)
*     DSB: David S Berry (JAC, Hawaii)
*     {enter_new_authors_here}

*  History:
*     2007 March 16 (MJC):
*        Original version.
*     2007 May 21 (MJC):
*        Remove the conversions from PIXEL to the reporting Frame.
*     2007 May 30 (MJC):
*        Add NBEAM, POLAR, and POLSIG arguments to report polar
*        co-ordinates of secondary-beam features.
*     2007 June 11 (MJC):
*        Made RMS single precision.
*     2007 June 15 (MJC):
*        Add REFOFF argument and parameter.
*     2009 January 31 (MJC):
*        Fix bug storing second and higher dimensions of CENTRE.
*        Increase precision of sky co-ordinates for CENTRE and REFOFF
*        to a hundreth of an arcsecond.
*     2009 February 2 (MJC):
*        Made the last change more general using Digits attribute and
*        checking for AsTime axes.
*     2009 November 3 (DSB):
*        Avoid accessing SkyFrame attributes if the supplied Frame is not
*        a SkyFrame.
*     {enter_further_changes_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'MSG_PAR'          ! Message-system public constants
      INCLUDE 'PRM_PAR'          ! PRIMDAT public constants
      INCLUDE 'NDF_PAR'          ! NDF constants
      INCLUDE 'AST_PAR'          ! AST constants and functions
      INCLUDE 'BF_PAR'           ! BEAMFIT constants

*  Arguments Given:
      INTEGER RFRM
      INTEGER MAP
      INTEGER NAXR
      INTEGER NP
      DOUBLE PRECISION P( NP )
      DOUBLE PRECISION SIGMA( NP )
      INTEGER NBEAM
      DOUBLE PRECISION REFOFF( 2 )
      DOUBLE PRECISION POLAR( 2, NBEAM )
      DOUBLE PRECISION POLSIG( 2, NBEAM )
      DOUBLE PRECISION RMS

*  Status:
      INTEGER STATUS             ! Global status

*  Local Constants:
      INTEGER BUFSIZ             ! Buffers' dimension
      PARAMETER ( BUFSIZ = 2 * ( BF__MXPOS - 1 ) )

      DOUBLE PRECISION PI
      PARAMETER ( PI = 3.1415926535898 )

      DOUBLE PRECISION R2D       ! Radians to degrees
      PARAMETER ( R2D = 180.0D0 / PI )

*  Local Variables:
      CHARACTER*9 ATTR           ! Buffer for attribute name
      CHARACTER*50 AXVAL         ! A formatted axis value
      CHARACTER*12 FMAT( 2 )     ! SkyFrame format
      INTEGER IAT                ! No. of characters currently in buffer
      INTEGER IB                 ! Beam loop counter
      LOGICAL ISSKY              ! Is RFRM a SkyFrame?
      INTEGER J                  ! Loop count
      INTEGER K                  ! Loop count
      INTEGER LAT                ! Index to latitude axis in SkyFrame
      CHARACTER*128 LINE( BUFSIZ ) ! Buffer for output text
      DOUBLE PRECISION S2FWHM    ! Sigma-to-FWHM conversion
      INTEGER PREC( 2 )          ! Number of digits of precision
      LOGICAL TIME( 2 )          ! Coordinates formatted as times?
      DOUBLE PRECISION WORK( 2 ) ! Work array for storing values
                                 ! and errors
      REAL WORKER( BUFSIZ )      ! Work array for storing values
                                 ! and errors

*.

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Some attributes are only defined for SkyFrames, so see if the results
*  Frame is a SkyFrame.
      ISSKY = AST_ISASKYFRAME( RFRM , STATUS )

*  Inquire current number of SkyFrame format precision digits
*  and whether the axis should be formatted as a time axis.
*  Not all types of Frame have an AsTime attribute, so check for
*  and annull any errors that occur when getting the value of AsTime.
      PREC( 1 ) = AST_GETI( RFRM, 'Digits(1)', STATUS )
      PREC( 2 ) = AST_GETI( RFRM, 'Digits(2)', STATUS )
      IF( ISSKY ) THEN
         TIME( 1 ) = AST_GETL( RFRM, 'AsTime(1)', STATUS )
         TIME( 2 ) = AST_GETL( RFRM, 'AsTime(2)', STATUS )
      ELSE
         TIME( 1 ) = .FALSE.
         TIME( 2 ) = .FALSE.
      END IF

*  Provide sufficient precision for sky co-ordinates.  Use three
*  figures are the decimals seconds of time and two digits of
*  arcseconds.  Allow for negative sign that appears to count as a
*  digit.
      DO J = 1, 2
         ATTR = 'Digits('
         IAT = 7
         CALL CHR_PUTI( J, ATTR, IAT )
         CALL CHR_APPND( ')', ATTR, IAT )
         IF ( TIME( J ) .OR. P( J ) .LT. 0.0D0 ) THEN
            CALL AST_SETI( RFRM, ATTR( :IAT ), 9, STATUS )
         ELSE
            CALL AST_SETI( RFRM, ATTR( :IAT ), 8, STATUS )
         END IF
      END DO

*  CENTRE
*  ======

*  Now write the primary-beam position out to the output parameters.
*  The complete set of axis values (separated by spaces) is written to
*  a buffer.
      IAT = 0
      LINE( 1 ) = ' '

      DO J = 1, NAXR
         AXVAL = AST_FORMAT( RFRM, J, P( J ), STATUS )
         CALL CHR_APPND( AXVAL, LINE( 1 ), IAT )
         IAT = IAT + 1
      END DO

*  Record the errors in the second element of the buffer.
      IAT = 0
      LINE( 2 ) = ' '
      DO J = 1, NAXR
         IF ( SIGMA( J ) .NE. VAL__BADD ) THEN
            AXVAL = AST_FORMAT( RFRM, J, SIGMA( J ), STATUS )
         ELSE
            AXVAL = 'bad'
         END IF
         CALL CHR_APPND( AXVAL, LINE( 2 ), IAT )
         IAT = IAT + 1
      END DO

*  Record the formattd co-ordinates and correspending errors in the
*  output parameter.
      CALL PAR_PUT1C( 'CENTRE', 2, LINE, STATUS )

*  FWHMs
*  =====
      S2FWHM = SQRT( 8.D0 * LOG( 2.D0 ) )

      WORK( 1 ) = P( 3 ) * S2FWHM
      WORK( 2 ) = SIGMA( 3 ) * S2FWHM
      CALL PAR_PUT1D( 'MAJFWHM', 2, WORK, STATUS )

      WORK( 1 ) = P( 4 ) * S2FWHM
      WORK( 2 ) = SIGMA( 4 ) * S2FWHM
      CALL PAR_PUT1D( 'MINFWHM', 2, WORK, STATUS )

*  ORIENT
*  ======

* Convert to degrees.  May need a +/- 90 later...
      WORK( 1 ) = P( 5 ) * R2D
      WORK( 2 ) = SIGMA( 5 ) * R2D
      CALL PAR_PUT1D( 'ORIENT', 2, WORK, STATUS )

*  AMP
*  ===
      WORK( 1 ) = P( 6 )
      WORK( 2 ) = SIGMA( 6 )
      CALL PAR_PUT1D( 'AMP', 2, WORK, STATUS )

*  BACK
*  ====
      WORK( 1 ) = P( 7 )
      WORK( 2 ) = SIGMA( 7 )
      CALL PAR_PUT1D( 'BACK', 2, WORK, STATUS )

*  RMS
*  ===
      CALL PAR_PUT0R( 'RMS', SNGL( RMS ), STATUS )

*  OFFSET of primary beam
*  ======================

*  Obtain the latitude axis so that the required precision
*  is used.
      IF( ISSKY ) THEN
         LAT = AST_GETI( RFRM, 'LatAxis', STATUS )
      ELSE
         LAT = 1
      END IF

*  Write the primary-beam offset and error out to the output
*  parameter.  Both values are written to REFOFF.
      LINE( 1 ) = AST_FORMAT( RFRM, LAT, REFOFF( 1 ), STATUS )

      IF ( REFOFF( 2 ) .NE. VAL__BADD ) THEN
         LINE( 2 ) = AST_FORMAT( RFRM, LAT, REFOFF( 2 ), STATUS )
      ELSE
         LINE( 2 ) = 'bad'
      END IF

      CALL PAR_PUT1C( 'REFOFF', 2, LINE, STATUS )


*  OFFSET and PA of secondary beam positions
*  =========================================
      IF ( NBEAM .GT. 1 ) THEN
         K = 0
         DO IB = 2, NBEAM

*  Now write the secondary-beam polar position and error out to the output
*  parameters.  The complete set of values (separated by spaces) is
*  written to OFFSET.
            K = K + 1
            LINE( K ) = AST_FORMAT( RFRM, 1, POLAR( 1, IB ), STATUS )

            K = K + 1
            IF ( POLSIG( 1, IB ) .NE. VAL__BADD ) THEN
               LINE( K ) = AST_FORMAT( RFRM, 1, POLSIG( 1, IB ),
     :                                 STATUS )
            ELSE
               LINE( K ) = 'bad'
            END IF

*  PA
*  ==
            WORKER( K - 1 ) = SNGL( POLAR( 2, IB ) )
            IF ( POLSIG( 1, IB ) .NE. VAL__BADD ) THEN
               WORKER( K ) = SNGL( POLSIG( 2, IB ) )
            ELSE
               WORKER( K ) = VAL__BADR
            END IF
         END DO

         CALL PAR_PUT1C( 'OFFSET', K, LINE, STATUS )
         CALL PAR_PUT1R( 'PA', K, WORKER, STATUS )
      END IF

*  Reset the SkyFrame precisions to their original values.
      CALL AST_SETI( RFRM, 'Digits(1)', PREC( 1 ), STATUS )
      CALL AST_SETI( RFRM, 'Digits(2)', PREC( 2 ), STATUS )

      END
