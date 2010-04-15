      SUBROUTINE MERGE(NPARAMS,PARAMS,
     &             STK_TITLE,STK_LAMBDA,STK_STOKES_I,STK_STOKES_Q,
     &             STK_STOKES_QV,STK_STOKES_U,STK_STOKES_UV,
     &             STK_NPTS,TOP_STK,NPTS,LAMBDA,STOKES_I,STOKES_Q,
     &             STOKES_QV,STOKES_U,STOKES_UV,TITLE,OUT_LU)
C+
C
C Subroutine:
C
C    M E R G E
C
C
C Author: Tim Harries (tjh@st-and.ac.uk)
C
C Parameters:
C
C NPARAMS (<), PARAMS (<),
C STK_TITLE (<), STK_LAMBDA (<), STK_STOKES_I (<), STK_STOKES_Q (<),
C STK_STOKES_QV (<), STK_STOKES_U (<), STK_STOKES_UV (<),
C STK_NPTS (<), TOP_STK (<), NPTS (>), LAMBDA (>), STOKES_I (>),
C STOKES_Q (>), STOKES_QV (>), STOKES_U (>), STOKES_UV (>), TITLE (>),
C OUT_LU (<)
C
C History:
C
C   May 1994 Created
C
C
C
C Merges two polarization spectra.
C
C
C
C-

      IMPLICIT NONE
      INTEGER OUT_LU
      INCLUDE 'array_size.inc'
      INTEGER NPARAMS
      REAL PARAMS(*)
      INTEGER SPEC1
      CHARACTER*80 STK_TITLE(MAXSPEC)
      REAL STK_LAMBDA(MAXPTS,MAXSPEC)
      INTEGER STK_NPTS(MAXSPEC)
      REAL STK_STOKES_I(MAXPTS,MAXPTS)
      REAL STK_STOKES_Q(MAXPTS,MAXPTS)
      REAL STK_STOKES_QV(MAXPTS,MAXPTS)
      REAL STK_STOKES_U(MAXPTS,MAXPTS)
      REAL STK_STOKES_UV(MAXPTS,MAXPTS)
      INTEGER TOP_STK
      REAL TMP_STOKES_I(MAXPTS)
      REAL TMP_STOKES_Q(MAXPTS)
      REAL TMP_STOKES_QV(MAXPTS)
      REAL TMP_STOKES_U(MAXPTS)
      REAL TMP_STOKES_UV(MAXPTS)
      REAL TMP_LAMBDA(MAXPTS)
      REAL LAMBDA(*)
      REAL STOKES_I(*)
      REAL STOKES_Q(*)
      REAL STOKES_QV(*)
      REAL STOKES_U(*)
      REAL STOKES_UV(*)
      INTEGER NPTS
      INTEGER I
      REAL SQ,SQ2
      REAL SU,SU2
      REAL SQV,SQV2
      REAL SUV,SUV2
      REAL WI,WI2
      REAL WQ,WQ2
      REAL WU,WU2
      INTEGER TMP_NPTS
      CHARACTER*(*) TITLE
      LOGICAL OK

      IF (NPARAMS.EQ.0) THEN
       CALL GET_PARAM('Stack spectrum',PARAMS(1),OK,OUT_LU)
       IF (.NOT.OK) GOTO 666
       NPARAMS = 1
      ENDIF
C
      IF (NPARAMS.GT.2) THEN
       CALL WR_ERROR('Additional parameters ignored',OUT_LU)
      ENDIF
C
      SPEC1 = INT(PARAMS(1))
      IF ( (SPEC1.LT.0 ).OR.(SPEC1.GT.TOP_STK) ) THEN
       CALL WR_ERROR('Stack spectrum out of stack range',OUT_LU)
       GOTO 666
      ENDIF
C
      IF ((STK_NPTS(SPEC1)+NPTS).GT.MAXPTS) THEN
        CALL WR_ERROR('Merged spectrum too big',OUT_LU)
        CALL WR_ERROR('Only part of stack spectrum merged',OUT_LU)
      ENDIF
C
      DO I = 1,STK_NPTS(SPEC1)
       IF (NPTS.LT.MAXPTS) THEN
        NPTS=NPTS+1
        LAMBDA(NPTS)=STK_LAMBDA(I,SPEC1)
        STOKES_I(NPTS)=STK_STOKES_I(I,SPEC1)
        STOKES_Q(NPTS)=STK_STOKES_Q(I,SPEC1)
        STOKES_QV(NPTS)=STK_STOKES_QV(I,SPEC1)
        STOKES_U(NPTS)=STK_STOKES_U(I,SPEC1)
        STOKES_UV(NPTS)=STK_STOKES_UV(I,SPEC1)
       ENDIF
      ENDDO
C
      CALL SSORT(NPTS,LAMBDA,STOKES_I,STOKES_Q,STOKES_QV,
     &           STOKES_U,STOKES_UV)
C
      TMP_NPTS=0
      I=1
      DO WHILE(I.LE.NPTS)
       IF (I.EQ.NPTS) THEN
        TMP_NPTS=TMP_NPTS+1
        TMP_STOKES_I(TMP_NPTS)=STOKES_I(I)
        TMP_STOKES_Q(TMP_NPTS)=STOKES_Q(I)
        TMP_STOKES_QV(TMP_NPTS)=STOKES_QV(I)
        TMP_STOKES_U(TMP_NPTS)=STOKES_U(I)
        TMP_STOKES_UV(TMP_NPTS)=STOKES_UV(I)
        TMP_LAMBDA(TMP_NPTS)=LAMBDA(I)
        I=I+1
       ELSE
        IF (LAMBDA(I).EQ.LAMBDA(I+1)) THEN
         TMP_NPTS=TMP_NPTS+1
         WI=1./STOKES_I(I)
         WI2=1./STOKES_I(I+1)
         SQ=STOKES_Q(I)/STOKES_I(I)
         SQV=STOKES_QV(I)/STOKES_I(I)**2
         SU=STOKES_U(I)/STOKES_I(I)
         SUV=STOKES_UV(I)/STOKES_I(I)**2
         SQ2=STOKES_Q(I+1)/STOKES_I(I+1)
         SQV2=STOKES_QV(I+1)/STOKES_I(I+1)**2
         SU2=STOKES_U(I+1)/STOKES_I(I+1)
         SUV2=STOKES_UV(I+1)/STOKES_I(I+1)**2
         WQ=1./SQV
         WQ2=1./SQV2
         WU=1./SU2
         WU2=1./SUV2
         TMP_STOKES_I(TMP_NPTS)=
     &   (STOKES_I(I)*WI+STOKES_I(I+1)*WI2)/(WI+WI2)
         TMP_STOKES_Q(TMP_NPTS)=(SQ*WQ+SQ2*WQ2)/(WQ+WQ2)
         TMP_STOKES_QV(TMP_NPTS)=1./(WQ+WQ2)
         TMP_STOKES_U(TMP_NPTS)=TMP_STOKES_I(TMP_NPTS)*(SU+SU2)/2.
         TMP_STOKES_UV(TMP_NPTS)=1./(WU+WU2)
         TMP_STOKES_Q(TMP_NPTS)=TMP_STOKES_Q(TMP_NPTS)*
     &                         TMP_STOKES_I(TMP_NPTS)
         TMP_STOKES_QV(TMP_NPTS)=TMP_STOKES_QV(TMP_NPTS)*
     &                         TMP_STOKES_I(TMP_NPTS)**2
         TMP_STOKES_U(TMP_NPTS)=TMP_STOKES_U(TMP_NPTS)*
     &                         TMP_STOKES_I(TMP_NPTS)
         TMP_STOKES_UV(TMP_NPTS)=TMP_STOKES_UV(TMP_NPTS)*
     &                         TMP_STOKES_I(TMP_NPTS)**2
         TMP_LAMBDA(TMP_NPTS)=LAMBDA(I)
         I=I+2
        ELSE
         TMP_NPTS=TMP_NPTS+1
         TMP_STOKES_I(TMP_NPTS)=STOKES_I(I)
         TMP_STOKES_Q(TMP_NPTS)=STOKES_Q(I)
         TMP_STOKES_QV(TMP_NPTS)=STOKES_QV(I)
         TMP_STOKES_U(TMP_NPTS)=STOKES_U(I)
         TMP_STOKES_UV(TMP_NPTS)=STOKES_UV(I)
         TMP_LAMBDA(TMP_NPTS)=LAMBDA(I)
         I=I+1
        ENDIF
       ENDIF
      ENDDO
      NPTS=TMP_NPTS
      DO I=1,NPTS
       STOKES_I(I)=TMP_STOKES_I(I)
       STOKES_Q(I)=TMP_STOKES_Q(I)
       STOKES_QV(I)=TMP_STOKES_QV(I)
       STOKES_U(I)=TMP_STOKES_U(I)
       STOKES_UV(I)=TMP_STOKES_UV(I)
       LAMBDA(I)=TMP_LAMBDA(I)
      ENDDO
      TITLE='Merged data'
666   CONTINUE
      END
