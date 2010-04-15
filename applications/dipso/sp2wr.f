       SUBROUTINE SP2WR(PARAMS,TITLE,IHHEAD,WORKSZ,WORK,NPOINT,WAVE,
     :                  FLUX,NBREAK,BREAK,SUBCHK,STATUS)

       IMPLICIT NONE
       INCLUDE 'SAE_PAR'
       INTEGER STATUS

       CHARACTER*80 PARAMS
       CHARACTER*79 TITLE, IHHEAD
       INTEGER WORKSZ, NPOINT, NBREAK
       INTEGER BREAK(NBREAK)
       INTEGER INUM, IX, MAXOUT

       REAL WORK(WORKSZ), WAVE(NPOINT), FLUX(NPOINT)

       LOGICAL SUBCHK

*
       IF( STATUS .NE. SAI__OK ) RETURN
       SUBCHK = .TRUE.

       CALL SPLOAD('SP2WR',PARAMS,TITLE,IHHEAD,WORKSZ,WORK,NPOINT,WAVE,
     :             FLUX,NBREAK,BREAK,INUM,MAXOUT,SUBCHK,STATUS)
       IF( STATUS .NE. SAI__OK ) GO TO 100
       IF (.NOT.SUBCHK) THEN
          CLOSE (61)
          GOTO 100
       ENDIF

       WRITE (61,'('' '',A79)') TITLE(1:79)
       IHHEAD(1:79) = ' '
       IHHEAD(1:) = ' Written in SPECTRUM 2 format'
       WRITE (61,'(A79)') IHHEAD(1:79)
       WRITE (61,'(I10)') INUM
       WRITE (61,'(3(1P2E13.5,3X))')
     : (WORK(IX),WORK(IX+MAXOUT),IX=1,INUM)
       CLOSE (61)

  100  CONTINUE

       END
