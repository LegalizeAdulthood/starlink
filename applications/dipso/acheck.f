      SUBROUTINE ACHECK(A,INDX,IREL,NL,IM,SUBCHK)


      INCLUDE 'KUSE_COM'   ! Declares common block KUSE holding K1 and K2

      LOGICAL SUBCHK

      CHARACTER*40 ITXT

      DIMENSION A(80),IREL(80),INDX(80)
      DIMENSION XV(5,1000),FXV(5,1000),ARP(5),IXV(5),NXV(5),ITXT(5)
      DIMENSION WVF(5),CFLX(5)

      COMMON/DAT4/XV,FXV,ARP,WVF,CFLX,IXV,NXV,NPROF
      COMMON/DAT4A/ITXT
      COMMON/DAT5/NDIM,NDI2,NPAR,NUMFIT,NCUR,MAXFC
      COMMON/DEBUG/NY

C  CHECK LINE PARAMETER DAT IS COMPLETE
C  DETERMINE NUMBER OF LINES
C
       SUBCHK = .TRUE.
      IM=0
      NDI3=3*NDIM
      IF(NL.EQ.0) THEN
        IF(NPAR.EQ.0) SUBCHK=.FALSE.
        RETURN
      ENDIF
C  PRINT WARNING OF MISSING PARAMETERS
C
      DO I=1,NL
      DO J=1,4
      IJ=(J-1)*NDIM+I
      IF(INDX(IJ).EQ.0) THEN
      IF(J.EQ.3) INDX(IJ)=1
      IF(J.EQ.4) INDX(IJ)=2
C  ALLOW UNDEFINED WIDTH IN THE CASE OF A NUMERICAL PROFILE
C
      IF(J.EQ.2) THEN
      IP=NDI3+I
      IQ=A(IP)+0.1
      IF(IQ.LE.5.AND.IREL(IP).EQ.0) THEN
      IM=IM+1
      WRITE(6,200) I,K2(J)
      ELSE
      INDX(IJ)=2
      ENDIF
      ENDIF
      IF(J.EQ.1) THEN
      IM=IM+1
      WRITE(6,200) I,K2(J)
      ENDIF
      ENDIF
      ENDDO
      ENDDO
C
C  CHECK FOR ILLEGAL PROFILES
      DO I=1,NL
        IJ=I+NDI3
        IP=A(IJ)+0.1
        IF(IP.GT.2) THEN
          IF(IP.LT.6) THEN
            WRITE(6,201) K2(4),IP
            IM=IM+1
          ELSE
            IF(IP.GT.(NPROF+5)) THEN
              WRITE(6,201) K2(4),IP
              IM=IM+1
            ENDIF
          ENDIF
        ENDIF
      ENDDO
  200 FORMAT('   Missing information for line',I4,3X,A9)
  201 FORMAT(1X,A9,I3,'  not available')
      RETURN
      END
