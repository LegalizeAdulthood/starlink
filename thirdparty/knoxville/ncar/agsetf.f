C
C ---------------------------------------------------------------------
C
      SUBROUTINE AGSETF (TPID,FUSR)
C
      CHARACTER*(*) TPID
      DIMENSION FURA(1)
C
C The routine AGSETF may be used to set the real (floating-point) value
C of any single AUTOGRAPH control parameter.
C
      FURA(1)=FUSR
      CALL AGSETP (TPID,FURA,1)
      RETURN
C
      END
