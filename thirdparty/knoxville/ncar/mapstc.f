C
C-----------------------------------------------------------------------
C
      SUBROUTINE MAPSTC (WHCH,CVAL)
C
      CHARACTER*(*) WHCH,CVAL
C
C Declare required common blocks.  See MAPBD for descriptions of these
C common blocks and the variables in them.
C
      COMMON /MAPCM3/ ITPN,NOUT,NPTS,IGID,BLAG,SLAG,BLOG,SLOG,PNTS(200)
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
      CALL Q8QST4 ('GRAPHX','EZMAP','MAPSTC','VERSION  1')
C
      IF (WHCH(1:2).EQ.'OU') THEN
        I=IDICTL(CVAL,DDCT,5)
        IF (I.EQ.0) GO TO 901
        NOUT=I-1
      ELSE
        GO TO 902
      END IF
C
C Done.
C
      RETURN
C
C Error exits.
C
  901 IIER=11
      CALL MAPCEM (' MAPSTC - UNKNOWN OUTLINE NAME ',CVAL,IIER,1)
      RETURN
C
  902 IIER=12
      CALL MAPCEM (' MAPSTC - UNKNOWN PARAMETER NAME ',WHCH,IIER,1)
      RETURN
C
      END
