C
      SUBROUTINE GAUF2(GX,GXVALS,GN,GINFP,GINFH,GINFW,GAUSUM)
C
C      G A U F 2
C
C      Creates the new Gaussian profile summed with the
C      previously created ones
C
C
C     Parameters -  (">" input, "<" output )
C
C     (>) GX      (Integer) Number of values in array GXVALS
C     (>) GXVALS  (Real array) X values of the line profile
C     (>) GN      (Integer) Total number of Gaussians
C     (>) GINFP   (Real array) The X positions of the Gaussian peaks
C     (>) GINFH   (Real array) The peak heights of the Gaussian peaks
C     (>) GINFW   (Real array) The sigma widths of the Gaussian peaks
C     (<) GAUSUM  (Real array) The Y values of the Gaussians+continuum
C
C                                             JRW / AAO  February 1987
C
C     Modified:
C       Original
C
      IMPLICIT NONE
C
C     Parameters
C
      INTEGER GX,GN
      REAL GXVALS(GX),GINFP(GN),GINFH(GN),GINFW(GN),
     :GAUSUM(GX)
C
C     Local variables
C
      INTEGER I,J
      REAL TT,YAA

      IF (GN.EQ.0) THEN
        GO TO 99
      END IF
C
C     Initialize GAUSUM
C
      DO I=1,GX
        GAUSUM(I)=0.0
      END DO
C
C     Form the sum of all the Gaussians
C
      DO J=1,GN
        DO I=1,GX
          TT=0.5*(((GXVALS(I)-GINFP(J))/GINFW(J))**2.)
          IF (TT.GT.20.) THEN
            YAA=0.0
            GO TO 5
          END IF
          IF (TT.LT.1.E-20) THEN
            YAA=GINFH(J)
            GO TO 5
          END IF
4         YAA=GINFH(J)*EXP(-1.*(TT))
5         GAUSUM(I)=GAUSUM(I)+YAA
        END DO
      END DO

99    END
