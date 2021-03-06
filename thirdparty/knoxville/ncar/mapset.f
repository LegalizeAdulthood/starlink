C
C-----------------------------------------------------------------------
C
      SUBROUTINE MAPSET (ARG1,ARG2,ARG3,ARG4,ARG5)
C
      CHARACTER*(*) ARG1
      DIMENSION ARG2(2),ARG3(2),ARG4(2),ARG5(2)
C
C Declare required common blocks.  See MAPBD for descriptions of these
C common blocks and the variables in them.
C
      COMMON /MAPCM4/ INTF,JPRJ,PHIA,PHIO,ROTA,ILTS,PLA1,PLA2,PLA3,PLA4,
     +                PLB1,PLB2,PLB3,PLB4,PLTR,GRID,IDSH,IDOT,LBLF,PRMF,
     +                ELPF,XLOW,XROW,YBOW,YTOW,IDTL,GRDR,SRCH,ILCW
      LOGICAL         INTF,LBLF,PRMF,ELPF
      COMMON /MAPCM5/ DDCT(5),LDCT(5),PDCT(10)
      CHARACTER*2     DDCT,LDCT,PDCT
      COMMON /MAPCMB/ IIER
C
C The following call gathers statistics on library usage at NCAR.
C
      CALL Q8QST4 ('GRAPHX','EZMAP','MAPSET','VERSION  1')
C
C Transfer the parameters defining the map limits.
C
      I=IDICTL(ARG1,LDCT,5)
      IF (I.EQ.0) GO TO 901
      ILTS=I
C
      PLA1=ARG2(1)
      PLA2=ARG3(1)
      PLA3=ARG4(1)
      PLA4=ARG5(1)
C
      IF (I.EQ.3) THEN
        PLB1=ARG2(2)
        PLB2=ARG3(2)
        PLB3=ARG4(2)
        PLB4=ARG5(2)
      END IF
C
C Set the flag to indicate that initialization is now required.
C
      INTF=.TRUE.
C
C Done.
C
      RETURN
C
C Error exit.
C
  901 IIER=10
      CALL MAPCEM (' MAPSET - UNKNOWN MAP AREA SPECIFIER ',ARG1,IIER,1)
      RETURN
C
      END
