C+
      SUBROUTINE FIG_GFIT(XCEN,FWHM,STREN,NLC,NHC,CONT0,S2NF,Y,
     :  NX,NL,NH)
C
C     F I G _ G F I T  -  LINE CENTRE DETERMINATION BY PSEUDO-GAUSSIAN FITTING
C
C
C   ARGUMENTS :
C
C     XCEN     D  F  CENTRE POSITION OF LINE RELATIVE TO CENTRE OF FIRST
C                       ELEMENT IN ARRAY Y.
C
C     FWHM     S  F  ZERO = FIT FULL-WIDTH HALF-MAXIMUM
C                    NON-ZERO = CONSTRAINED FULL-WIDTH HALF-MAXMIMUM
C              D  F  FITTED FULL-WIDTH HALF-MAXIMUM IF ZERO SOURCE
C
C     STREN    D  F  INTEGRATED STRENGTH OF LINE ALLOWING FOR CONTINUUM.
C
C     NLC      D  I  LOW INDEX LIMIT OF REGION FOUND TO CONTAIN LINE.
C
C     NHC      D  I  HIGH INDEX LIMIT OF REGION FOUND TO CONTAIN LINE.
C
C     CONT0    D  F  CONTINUUM LEVEL AT BIN CONTAINING MAXIMUM VALUE
C                       IN THE RANGE INDEX NL TO INDEX NH.
C
C     S2NF     D  F  SIGNAL-TO-NOISE FIGURE  +1.0 = PURE SIGNAL
C                                            -1.0 = PURE NOISE
C
C
C     Y        S  F  SOURCE ARRAY IN WHICH LINE IS TO BE FOUND.
C
C     NX       S  I  NUMBER OF ELEMENTS IN ARRAY Y
C
C     NL       S  I  LOW INDEX LIMIT OF REGION IN ARRAY Y IN WHICH
C                       THE LINE IS TO BE FOUND.
C
C                       FOUND.
C     NH       S  I  HIGH INDEX LIMIT OF REGION IN ARRAY Y IN WHICH
C                       THE LINE IS TO BE FOUND.
C
C
C   THIS ROUTINE FITS A QUADRATIC POLYNOMIAL BY SOLVING THE
C   'NORMAL EQUATIONS'
C
C                 V = A.C
C
C   WHERE
C
C        V(J) IS THE SUM, OVER THE FITTED DATA, OF W(M)*Y(M)*X(M)**(J-1)
C        A(J,K) IS THE SUM, OVER THE FITTED DATA, OF W(M)*X(M)**(J+K-1)
C        W(M) IS THE WEIGHT GIVEN TO THE DATA POINT Y(M)
C        C(K) IS THE KTH COEFFICIENT OF THE FITTED POLYNOMIAL
C
C   THIS FIT IS DONE TO THE LOGARITHM OF THE EXCESS OF THE DATA OVER AN
C   ESTIMATED CONTINUUM AND THE WEIGHTING IS CHOSEN SO AS TO MAKE THIS
C   EQUIVALENT TO FITTING A GAUSSIAN TO THE ORIGINAL DATA.
C
C   HISTORY -
C
C   THIS IS JOHN STRAEDE'S SDRSYS ROUTINE GFIT, MODIFIED FOR USE ON
C   THE VAX, PARTICULARLY FOR FIGARO, BY KS.  24 FEB 88.
C   THE FOLLOWING CHANGES WERE MADE:
C
C   A) ROUTINE RE-NAMED TO FIG_GFIT
C   B) ALL INTEGERS NOW INTEGER*4 (VAX DEFAULT)
C   C) INTERDATA SPECIFIC COMPILER FLAGS ($TITL ETC) REMOVED
C   D) PARAMETER NX ADDED, SO NO LONGER ASSUMES LENGTH OF NX ELEMENTS
C   E) ALL REFERENCES TO 2048, 2050 ETC CHANGED TO NX, NX+2 ETC
C
C   The routine has been modified for use by CGS4 so that perfectly
C   valid oversampled Infra-Red lines are not rejected by the initial
C   checks. The constraint that there must be a single bin peak
C   has been relaxed to a constraint that there must not be a local
C   minimum. Modified by SMB/ROE on 30-May-1990.
C
C   G F I T  -  ARRAYS, CONSTANTS
C
C   ARGUMENT ARRAY
      REAL Y(NX)
C
C   EQUATION VALUES VECTOR
      REAL V(3)
      EQUIVALENCE (V(1),V0), (V(2),V1), (V(3),V2)
C
C   COEFFICIENTS OF SIMULTANEOUS EQUATIONS
      REAL A(3,3)
      EQUIVALENCE (A(1,1),A00), (A(1,2),A01), (A(1,3),A02)
     1          , (A(2,1),A10), (A(2,2),A11), (A(2,3),A12)
     2          , (A(3,1),A20), (A(3,2),A21), (A(3,3),A22)
C
C   COEFFICIENTS VECTOR (SOLUTION TO SIMULTANEOUS EQUATIONS)
      REAL C(3)
      EQUIVALENCE (C(1),C0), (C(2),C1), (C(3),C2)
C
C   POWERS OF X
      REAL X(3)
      EQUIVALENCE (X(1),X0), (X(2),X1), (X(3),X2)
C
C
C
C    0
C   X
      DATA X0 /1.0/
C
C   4.LN(2)
      DATA FOURL2 /2.7726/
C
      DATA SFA /2.44141E-4/
C
C   G F I T  -  FIND SMOOTHED PEAK
C
C   RESET STRENGTH AND SIGNAL-TO-NOISE-FIGURE
      STREN = 0.0
      S2NF = 0.0
C
C   CONSTRAINED FULL-WIDTH HALF-MAXIMUM
      FWHMS = FWHM *FWHM
      C2 = 0.0
      IF (FWHMS .GT. 0.0)   C2 = -FOURL2 /FWHMS
C
C   FIND MAXIMUM FOR LINE CENTRE
      YMAX = 0.0
      Y0 = 0.0
      IF (NL .GT. 1)   Y0 = Y(NL-1)
      YP1 = Y(NL)
C
      DO 10 N10 = NL,NH
C
         YM1 = Y0
         Y0  = YP1
         YP1 = 0.0
         IF (N10 .LT. NX)   YP1 = Y(N10+1)
         YBAR = (YM1 + 2.*Y0 +YP1) /4.
         IF (YBAR .LT. YMAX)   GO TO 10
C                                       NOT MAXIMUM
            YMAX = YBAR
            NC = N10
  10     CONTINUE
C
      NHC = (NL +NH +1) /2
      IF (NC .EQ. NH)   GO TO 30
C                                NO LINE OR LINE AT RED END OF REGION
      IF (YMAX .LE. 0.0)   GO TO 30
C                                   NO POSITIVE MAXIMUM

C   *** This was the old code

!C   CHECK FOR LOCAL PEAK
!      IF (Y(NC-1) .GE. Y(NC)  .AND.  Y(NC) .LE. Y(NC+1))   GO TO 30
!C                                                                NO PEAK

C   *** Here is the new code (modified by SMB on 30-May-1990).

C   CHECK THIS IS NOT A LOCAL MINIMUM
      IF (Y(NC-1) .GT. Y(NC)  .AND.  Y(NC) .LT. Y(NC+1))   GO TO 30
C                                                                NOT A PEAK

C   G F I T  -  FIND LINE BOUNDARIES
C
C   RED BOUNDARY
      NHC = NC
      NCP1 = NC +1
C
      DO 12 N12 = NCP1,NX - 3
C
         SLOPE = Y(N12-1) + 2.*(Y(N12) -Y(N12+1)) -Y(N12+2)
         IF (SLOPE .LT. 0.0)   GO TO 121
C                                        RED MINIMUM FOUND
            NHC = N12
  12     CONTINUE
C
  121 CONTINUE
      IF (NHC .EQ. NC)   GO TO 30
C
C   BLUE BOUNDARY
      NLC = NC
      N14L = NX + 2 -NC
C
      DO 14 N14 = N14L,NX - 3
C
         N14X = NX + 1 -N14
         SLOPE = Y(N14X+1) +2.*(Y(N14X) -Y(N14X-1)) -Y(N14X-2)
         IF (SLOPE .LT. 0.0)   GO TO 141
C                                        BLUE MINIMUM FOUND
            NLC = N14X
  14     CONTINUE
C
  141 CONTINUE
      IF (NLC .EQ. NC)   GO TO 30
C
C   G F I T  -  GAUSSIAN CORE LIMITS AND CONTINUUM
C
C   FIND LIMITS OF GAUSSIAN CORE
C   BY MAXIMUMS OF SECOND DERIVATIVES
C
      D2MAX = Y(NC-2) + Y(NC-1) - 4.*Y(NC) + Y(NC+1) + Y(NC+2)
      D2MAXC = D2MAX
      NCP1 = NC +1
      NHW = NCP1
      IF (NCP1 .GT. NHC)   GO TO 161
C
      DO 16 N16 = NCP1,NHC
C
         D2YDX2 = Y(N16-2) +Y(N16-1) -4.*Y(N16) +Y(N16+1) +Y(N16+2)
         IF (D2YDX2 .LE. D2MAX)   GO TO 16
C
            NHW = N16
            D2MAX = D2YDX2
C
  16     CONTINUE
C
  161 CONTINUE
      D2MAX = D2MAXC
      NLW = NC -1
      N18L = NX + 2 -NC
      N18H = NX + 1 -NLC
      IF (N18L .GE. N18H)   GO TO 181
C
      DO 18 N18 = N18L,N18H
C
         N18X = NX + 1 -N18
         D2YDX2 = Y(N18X+2) +Y(N18X+1) -4.*Y(N18X) +Y(N18X-1) +Y(N18X-2)
         IF (D2YDX2 .LE. D2MAX)   GO TO 18
C
            NLW = N18X
            D2MAX = D2YDX2
C
  18     CONTINUE
C
  181 CONTINUE
C
C   CONTINUUM
      YCH = (Y(NHC-1) +3.*Y(NHC) +Y(NHC+1)) /5.
      YCL = (Y(NLC-1) +3.*Y(NLC) +Y(NLC+1)) /5.
      DX = FLOAT(NHC -NLC)
      DCDX = (YCH -YCL) /DX
      CONT0 = YCL + FLOAT(NC -NLC) *DCDX
C
C   G F I T  -  CONSTRUCT NORMAL EQUATIONS
C
C   RESET (CLEAR) NORMAL EQUATIONS
      DO 20 I = 1,3
         V(I) = 0.0
         DO 20 J = 1,3
            A(I,J) = 0.0
  20        CONTINUE
C
C   INTEGRATE STRENGTH ABOVE CONTINUUM AND ACCUMULATE NORMAL EQUATIONS
      NLCP1 = NLC +1
      NHCM1 = NHC -1
      NPTS = 0
      SUM = 0.0
C
      DO 24 N24 = NLCP1,NHCM1
C
         X1 = FLOAT(N24 -NC)
         CONT = CONT0 + DCDX *X1
         YXS = Y(N24) -CONT
         SUM = SUM +YXS
         IF (Y(N24) .LE. 0.0)   GO TO 24
C                                        NULL/NEGATIVE DATA
         IF (N24 .LT. NLW  .OR.  N24 .GT. NHW)   GO TO 24
C                                                         OUTSIDE CORE
         YXSONC = YXS /(ABS(YXS) + ABS(CONT))
         IF (YXSONC .LT. SFA)   GO TO 24
C                                        TERRIBLE DATA
            WEIGHT = YXS /SQRT(Y(N24))
            YXS = ALOG(YXS)
            X2 = X1 * X1
            YXS = YXS - C2 *X2
C
            DO 22 I = 1,3
C
               WX = WEIGHT *X(I)
               V(I) = V(I) + WX *YXS
C
               DO 22 J = 1,3
C
                  A(I,J) = A(I,J) + WX *X(J)
  22              CONTINUE
C
            NPTS = NPTS +1
C
  24     CONTINUE
C
C   LINE INTEGRATED STRENGTH
      STREN = SUM
C
C   G F I T  -  SOLVE NORMAL EQUATIONS
C
      IF (C2 .LT. 0.0)   GO TO 241
C                                  FULL-WIDTH HALFMAXIMUM CONSTRAINED
C   FIT FULL-WIDTH HALFMAXIMUM
      IF (NPTS .LT. 3)   GO TO 30
C                                 INSUFFICIENT DATA
C   SOLVE NORMAL EQUATIONS
      A00A22 = A00*A22
      A01A12 = A01*A12
      A01A22 = A01*A22
      A02A11 = A02*A11
      A02A20 = A02*A20
      A02A21 = A02*A21
      A10A22 = A10*A22
      A11A22 = A11*A22
      A12A20 = A12*A20
      A12A21 = A12*A21
      SNA = A22*V0 - A02*V2
      SNB = A11A22 - A12A21
      SNC = A22*V1 - A12*V2
      SND = A01A22 - A02A21
      SNE = A00A22 - A02A20
      SNF = A10A22 - A12A20
C
      SNEB = SNE*SNB
      SNFD = SNF*SND
      SNEBFD = SNEB - SNFD
      C0TEST = ABS(SNEBFD) / (ABS(SNEB) + ABS(SNFD))
      IF (C0TEST .LT. SFA)   GO TO 30
C                                     ILL CONDITIONED EQUATIONS
      C0 = (SNA*SNB - SNC*SND) /SNEBFD
C
      C1DEN = A01A12 - A02A11
      C1TEST = ABS(C1DEN) / (ABS(A01A12) + ABS(A02A11))
      IF (C1TEST .LT. SFA)   GO TO 30
C                                     ILL CONDITIONED EQUATIONS
      V00 = V0 - A00*C0
      C1 = (A12*V00 - A02*(V1 - A10*C0)) /C1DEN
      C2 = (V00 - A01*C1) /A02
      IF (C2 .GE. 0.0)   GO TO 30
C                                 NOT AN EMISSION LINE !
C   LINE FULLWIDTH-HALFMAXIMUM
      FWHM = SQRT(-FOURL2 /C2)
      GO TO 259
C
C   G F I T  -  LINE CENTRE DETERMINATION
C
C   FULL-WIDTH HALF-MAXIMUM CONSTRAINED
  241 CONTINUE
      IF (NPTS .LT. 2)   GO TO 30
C                                 INSUFFICIENT DATA
C   SOLVE FOR TWO COEFFICIENTS
      A00A11 = A00*A11
      A01A10 = A01*A10
      DET = A00A11 - A01A10
      TEST = ABS(DET) / (ABS(A00A11) + ABS(A01A10))
      IF (TEST .LT. SFA)   GO TO 30
C                                   ILL CONDITIONED EQUATIONS
      C0 = (A11 *V0 - A01*V1) /DET
      C1 = (A00*V1 - A10*V0) /DET
C
C   LINE CENTRE POSITION
  259 CONTINUE
      C1ON2 = C1 /2.
      C2NEG2 = -C2 *2.0
      IF (C2NEG2 .LT. ABS(C1ON2))   GO TO 30
C                                            MORE THAN 2 BINS FROM PEAK
      XCEN = FLOAT(NC -1) - C1ON2 /C2
C
C   GOODNESS OF FIT
      SUMERR = 0.0
      SUMFIT = 0.0
C
      DO 26 N26 = NLW,NHW
C
         X1 = FLOAT(N26 -NC)
         X2 = X1*X1
         FX = C0 + C1*X1 + C2*X2
         EFX = EXP(FX)
         CONT = CONT0 + DCDX *X1
         SIG = Y(N26) -CONT
         IF (SIG .LE. 0.0)   GO TO 26
C                                     IGNORE NON-POSITIVE 'SIGNAL'
         ERR = SQRT(EFX) -SQRT(SIG)
         SUMERR = SUMERR + ERR*ERR
         SUMFIT = SUMFIT + EFX
  26     CONTINUE
C
      IF (SUMFIT .LE. 0.0)   GO TO 30
      S2NF = (SUMFIT -SUMERR) / (SUMFIT +SUMERR)
C
  30  CONTINUE
      RETURN
C
      END
