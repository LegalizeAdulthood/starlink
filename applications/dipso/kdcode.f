      SUBROUTINE KDCODE(KARD,KV1,KV2,F1,KODE,NDIM)

      EXTERNAL FNUM
!
      CHARACTER*1 BLEEP
      COMMON /BLEEP/ BLEEP
!
      DIMENSION KARD(80)

      data ihnull/1h /

      KV1=0
      KODE=0
      K1=1
      KTEMP=K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.EQ.0) GO TO 980
      CALL ELFKJ(KARD(K1),IT,IN,IK)
C  FIRST CHARACTER IS UNRECOGNISED OR ILLEGAL
C
      IF(IT.GT.2.OR.IN.EQ.0) GO TO 990
C  FIRST CHARACTER IS A COMMAND
C
      IF(IT.EQ.1) THEN
      IN=(IN+1)/2
      KV1=-IN
      RETURN
      ENDIF
C  FIRST CHARACTER IS A VARIABLE NAME
C
      CALL ELFVAR(I1,I2,KARD,K1,IF)
      IF(IF.NE.0) GO TO 990
      IF(I2.GT.NDIM) GO TO 950
      KV1=NDIM*(I1-1)+I2
C  CASE WHERE NO VARIABLE INDEX IS SUPPLIED
      IF(I2.EQ.0) THEN
        KV1=5*NDIM+I1
C  THROW OUT ALL EXCEPT VARIABLE D (COULD BE USED LATER)
        IF(I1.LT.5) GO TO 990
      ENDIF
      KTEMP=K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.EQ.0) GO TO 980
      CALL ELFKJ(KARD(K1),IT,IN,IK)
C  NEXT CHARACTER MUST BE EQUALS OR COLON
C
      IF(IK.NE.36.AND.IK.NE.38) GO TO 990
      IF(IK.EQ.38) KODE=1
      IF(IK.EQ.36) KODE=2
      K1=K1+1
      KTEMP=K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.EQ.0) GO TO 980
      CALL ELFKJ(KARD(K1),IT,IN,IK)
      IF(IT.EQ.1) GO TO 990
      IF(IT.EQ.4.AND.IN.GT.3) GO TO 990
      IF(IT.EQ.2.AND.KODE.EQ.1) GO TO 940
      IF(IT.EQ.2) GO TO 20
C  NUMBER FOLLOWS EQUALS
C
      CALL FNUM(T,KARD,K1,IF)
      IF(IF.NE.0) GO TO 990
      KTEMP = K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.NE.0) GO TO 11
      F1=T
      GO TO 1000
   11 CALL ELFKJ(KARD(K1),IT,IN,IK)
      IF(IT.NE.4) GO TO 990
      IF(IN.EQ.1.OR.IN.GT.5) GO TO 990
      IOP=IN
      K1=K1+1
      KTEMP = K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.EQ.0) GO TO 980
      CALL ELFKJ(KARD(K1),IT,IN,IK)
      IF(IT.NE.2) GO TO 990
      CALL ELFVAR(I3,I4,KARD,K1,IF)
      IF(IF.NE.0) GO TO 990
      IF(I1.NE.I3) GO TO 970
      IF(IOP.GT.3.AND.I3.LE.2) GO TO 960
      IF(IOP.LE.3.AND.I3.EQ.3) GO TO 960
      KV2=NDIM*(I3-1)+I4
      IF(IOP.EQ.5) T=1./T
      IF(IOP.EQ.2) T=-T
      F1=T
      KODE=3
      GO TO 1000
C  VARIABLE FOLLOWS EQUALS
C
   20 KODE=3
      CALL ELFVAR(I3,I4,KARD,K1,IF)
      IF(IF.NE.0) GO TO 990
      IF(I1.NE.I3) GO TO 970
      KV2=NDIM*(I3-1)+I4
      KTEMP = K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.NE.0) GO TO 35
      F1=0.
      IF(I3.EQ.3) F1=1.
      GO TO 1000
   35 CALL ELFKJ(KARD(K1),IT,IN,IK)
      IF(IT.NE.4) GO TO 990
      IF(IN.EQ.1.OR.IN.GT.5) GO TO 990
      IF(IN.GT.3.AND.I3.LE.2) GO TO 960
      IF(IN.LE.3.AND.I3.EQ.3) GO TO 960
      IOP=IN
      K1=K1+1
      KTEMP = K1
      K1=NEXTK(KARD,KTEMP)
      IF(K1.EQ.0) GO TO 980
      CALL ELFKJ(KARD(K1),IT,IN,IK)
      IF(IT.LE.2) GO TO 990
      IF(IT.EQ.4.AND.IN.GT.3) GO TO 990
      CALL FNUM(T,KARD,K1,IF)
      IF(IF.NE.0) GO TO 990
      IF(IOP.EQ.5) T=1./T
      IF(IOP.EQ.2) T=-T
      F1=T
      GO TO 1000
  990 WRITE(6,200) KARD(K1), BLEEP
  200 FORMAT('   ELFINP:  illegal character ',A1,A1)
      GO TO 999
!
  980 CONTINUE
       IHTEST = 0
       DO IHLOOP = 1, 80
          IF (KARD(IHLOOP).NE.IHNULL) IHTEST = IHTEST + 1
       ENDDO
       IF (IHTEST.NE.0) WRITE(6,201)
  201 FORMAT('   ELFINP:  incomplete construction')
!
      GO TO 999
  970 WRITE(6,202)
  202 FORMAT('   ELFINP:  equalities are only permitted between'/
     :       '           variables of the same type')
      GO TO 999
  960 WRITE(6,203)
  203 FORMAT('   ELFINP:  operator/variable incompatibility')
      GO TO 999
  950 WRITE(6,204) I2,NDIM
  204 FORMAT('   ELFINP:  number of variables exceeds array space'/
     :       '           (',I5,',',I5,')')
      KV1=-2
      GO TO 1000
  940 WRITE(6,205)
  205 FORMAT('   ELFINP:  starting values must be numeric')
  999 KV1=0
 1000 RETURN
      END
