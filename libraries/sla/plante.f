      SUBROUTINE sla_PLANTE (DATE, ELONG, PHI, JFORM, EPOCH,
     :                       ORBINC, ANODE, PERIH, AORQ, E,
     :                       AORL, DM, RA, DEC, R, JSTAT)
*+
*     - - - - - - -
*      P L A N T E
*     - - - - - - -
*
*  Topocentric apparent RA,Dec of a Solar-System object whose
*  heliocentric orbital elements are known.
*
*  Given:
*     DATE     d     MJD of observation (JD - 2400000.5, Notes 1,5)
*     ELONG    d     observer's east longitude (radians, Note 2)
*     PHI      d     observer's geodetic latitude (radians, Note 2)
*     JFORM    i     choice of element set (1-3; Notes 3-6)
*     EPOCH    d     epoch of elements (TT MJD, Note 5)
*     ORBINC   d     inclination (radians)
*     ANODE    d     longitude of the ascending node (radians)
*     PERIH    d     longitude or argument of perihelion (radians)
*     AORQ     d     mean distance or perihelion distance (AU)
*     E        d     eccentricity
*     AORL     d     mean anomaly or longitude (radians, JFORM=1,2 only)
*     DM       d     daily motion (radians, JFORM=1 only )
*
*  Returned:
*     RA,DEC   d     RA, Dec (topocentric apparent, radians)
*     R        d     distance from observer (AU)
*     JSTAT    i     status:  0 = OK
*                            -1 = illegal JFORM
*                            -2 = illegal E
*                            -3 = illegal AORQ
*                            -4 = illegal DM
*                            -5 = numerical error
*
*  Called: sla_EL2UE, sla_PLANTU
*
*  Notes:
*
*  1  DATE is the instant for which the prediction is required.  It is
*     in the TT timescale (formerly Ephemeris Time, ET) and is a
*     Modified Julian Date (JD-2400000.5).
*
*  2  The longitude and latitude allow correction for geocentric
*     parallax.  This is usually a small effect, but can become
*     important for near-Earth asteroids.  Geocentric positions can be
*     generated by appropriate use of routines sla_EVP (or sla_EPV) and
*     sla_PLANEL.
*
*  3  The elements are with respect to the J2000 ecliptic and equinox.
*
*  4  A choice of three different element-set options is available:
*
*     Option JFORM = 1, suitable for the major planets:
*
*       EPOCH  = epoch of elements (TT MJD)
*       ORBINC = inclination i (radians)
*       ANODE  = longitude of the ascending node, big omega (radians)
*       PERIH  = longitude of perihelion, curly pi (radians)
*       AORQ   = mean distance, a (AU)
*       E      = eccentricity, e (range 0 to <1)
*       AORL   = mean longitude L (radians)
*       DM     = daily motion (radians)
*
*     Option JFORM = 2, suitable for minor planets:
*
*       EPOCH  = epoch of elements (TT MJD)
*       ORBINC = inclination i (radians)
*       ANODE  = longitude of the ascending node, big omega (radians)
*       PERIH  = argument of perihelion, little omega (radians)
*       AORQ   = mean distance, a (AU)
*       E      = eccentricity, e (range 0 to <1)
*       AORL   = mean anomaly M (radians)
*
*     Option JFORM = 3, suitable for comets:
*
*       EPOCH  = epoch of elements and perihelion (TT MJD)
*       ORBINC = inclination i (radians)
*       ANODE  = longitude of the ascending node, big omega (radians)
*       PERIH  = argument of perihelion, little omega (radians)
*       AORQ   = perihelion distance, q (AU)
*       E      = eccentricity, e (range 0 to 10)
*
*     Unused arguments (DM for JFORM=2, AORL and DM for JFORM=3) are not
*     accessed.
*
*  5  Each of the three element sets defines an unperturbed heliocentric
*     orbit.  For a given epoch of observation, the position of the body
*     in its orbit can be predicted from these elements, which are
*     called "osculating elements", using standard two-body analytical
*     solutions.  However, due to planetary perturbations, a given set
*     of osculating elements remains usable for only as long as the
*     unperturbed orbit that it describes is an adequate approximation
*     to reality.  Attached to such a set of elements is a date called
*     the "osculating epoch", at which the elements are, momentarily,
*     a perfect representation of the instantaneous position and
*     velocity of the body.
*
*     Therefore, for any given problem there are up to three different
*     epochs in play, and it is vital to distinguish clearly between
*     them:
*
*     . The epoch of observation:  the moment in time for which the
*       position of the body is to be predicted.
*
*     . The epoch defining the position of the body:  the moment in time
*       at which, in the absence of purturbations, the specified
*       position (mean longitude, mean anomaly, or perihelion) is
*       reached.
*
*     . The osculating epoch:  the moment in time at which the given
*       elements are correct.
*
*     For the major-planet and minor-planet cases it is usual to make
*     the epoch that defines the position of the body the same as the
*     epoch of osculation.  Thus, only two different epochs are
*     involved:  the epoch of the elements and the epoch of observation.
*
*     For comets, the epoch of perihelion fixes the position in the
*     orbit and in general a different epoch of osculation will be
*     chosen.  Thus, all three types of epoch are involved.
*
*     For the present routine:
*
*     . The epoch of observation is the argument DATE.
*
*     . The epoch defining the position of the body is the argument
*       EPOCH.
*
*     . The osculating epoch is not used and is assumed to be close
*       enough to the epoch of observation to deliver adequate accuracy.
*       If not, a preliminary call to sla_PERTEL may be used to update
*       the element-set (and its associated osculating epoch) by
*       applying planetary perturbations.
*
*  6  Two important sources for orbital elements are Horizons, operated
*     by the Jet Propulsion Laboratory, Pasadena, and the Minor Planet
*     Center, operated by the Center for Astrophysics, Harvard.
*
*     The JPL Horizons elements (heliocentric, J2000 ecliptic and
*     equinox) correspond to SLALIB arguments as follows.
*
*       Major planets:
*
*         JFORM  = 1
*         EPOCH  = JDCT-2400000.5D0
*         ORBINC = IN (in radians)
*         ANODE  = OM (in radians)
*         PERIH  = OM+W (in radians)
*         AORQ   = A
*         E      = EC
*         AORL   = MA+OM+W (in radians)
*         DM     = N (in radians)
*
*         Epoch of osculation = JDCT-2400000.5D0
*
*       Minor planets:
*
*         JFORM  = 2
*         EPOCH  = JDCT-2400000.5D0
*         ORBINC = IN (in radians)
*         ANODE  = OM (in radians)
*         PERIH  = W (in radians)
*         AORQ   = A
*         E      = EC
*         AORL   = MA (in radians)
*
*         Epoch of osculation = JDCT-2400000.5D0
*
*       Comets:
*
*         JFORM  = 3
*         EPOCH  = Tp-2400000.5D0
*         ORBINC = IN (in radians)
*         ANODE  = OM (in radians)
*         PERIH  = W (in radians)
*         AORQ   = QR
*         E      = EC
*
*         Epoch of osculation = JDCT-2400000.5D0
*
*     The MPC elements correspond to SLALIB arguments as follows.
*
*       Minor planets:
*
*         JFORM  = 2
*         EPOCH  = Epoch-2400000.5D0
*         ORBINC = Incl. (in radians)
*         ANODE  = Node (in radians)
*         PERIH  = Perih. (in radians)
*         AORQ   = a
*         E      = e
*         AORL   = M (in radians)
*
*         Epoch of osculation = Epoch-2400000.5D0
*
*       Comets:
*
*         JFORM  = 3
*         EPOCH  = T-2400000.5D0
*         ORBINC = Incl. (in radians)
*         ANODE  = Node. (in radians)
*         PERIH  = Perih. (in radians)
*         AORQ   = q
*         E      = e
*
*         Epoch of osculation = Epoch-2400000.5D0
*
*  This revision:  19 June 2004
*
*  Copyright (C) 2004 P.T.Wallace.  All rights reserved.
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,
*    Boston, MA  02111-1307  USA
*
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,ELONG,PHI
      INTEGER JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,
     :                 AORL,DM,RA,DEC,R
      INTEGER JSTAT

      DOUBLE PRECISION U(13)


*  Transform conventional elements to universal elements.
      CALL sla_EL2UE(DATE,
     :               JFORM,EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,
     :               U,JSTAT)

*  If successful, make the prediction.
      IF (JSTAT.EQ.0) CALL sla_PLANTU(DATE,ELONG,PHI,U,RA,DEC,R,JSTAT)

      END
