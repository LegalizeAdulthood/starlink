      SUBROUTINE CAP_CPPAR (CIIN, CIOUT, STATUS)
*+
*  Name:
*     CAP_CPPAR
*  Purpose:
*     Create output cat. parameters corresponding to input cat. ones.
*  Language:
*     Fortran 77.
*  Invocation:
*     CALL CAP_CPPAR (CIIN, CIOUT; STATUS)
*  Description:
*     Create parameters in the output catalogue corresponding to those 
*     in the input catalogue.
*  Arguments:
*     CIIN  =  INTEGER (Given)
*        Identifier for the input catalogue.
*     CIOUT  =  INTEGER (Given)
*        Identifier for the output catalogue.
*     STATUS  =  INTEGER (Given and Returned)
*        The global status.
*  Algorithm:
*     Do while there are more parameters in the input catalogue.
*       Attempt to obtain an identifier for the next parameter in the
*       input catalogue.
*       If ok then
*         Inquire the details of the parameter.
*         Determine whether a parameter of the given name already
*         exists in the output catalogue.
*         If note then
*           Attempt to create a new parameter in the output catalogue.
*           Set the details of the new parameter.
*         else
*           Report a warning.
*         end if
*       else
*         Set the termination flag.
*       end if
*       If any error has occurred then
*         Set the termination flag.
*       end if
*     end do
*  Copyright:
*     Copyright (C) 1999 Central Laboratory of the Research Councils
*  Authors:
*     ACD: A C Davenhall (Leicester)
*  History:
*     2/7/94  (ACD): Original version.
*     30/9/94 (ACD): First stable version.
*     11/4/95 (ACD): Changed the name of the null identifier.
*     28/3/97 (ACD): Changed the definition of column and parameter
*        names to use the correct parametric contstant (CAT__SZCMP).
*     7/6/00  (ACD): Modified to check that a parameter does not
*        already exist in the output catalogue prior to copying it.
*  Bugs:
*     None known
*-
*  Type Definitions:
      IMPLICIT NONE
*  Global Constants:
      INCLUDE 'SAE_PAR'     ! Standard SAE symbolic constants.
      INCLUDE 'CAT_PAR'     ! CAT symbolic constants.
*  Arguments Given:
      INTEGER
     :  CIIN,
     :  CIOUT
*  Status:
      INTEGER STATUS        ! Global status.
*  External References:
      INTEGER CHR_LEN
*  Local Variables:
      LOGICAL
     :  MORE      ! Flag: more parameters or parameters to access?
      INTEGER
     :  QCOUNT,   ! Number of the current parameter.
     :  QIINC,    ! Identifier for the current input  parameter.
     :  QIOUTC    !     "       "   "     "    output   "   .

*
*    The following variables represent the attributes of the current
*    parameter.

      INTEGER
     :  QCI,         ! Parent catalogue.
     :  QDTYPE,      ! Data type.
     :  QCSIZE,      ! Size if a character string.
     :  QDIMS,       ! Dimensionality.
     :  QSIZEA(10),  ! Size of each array dimension.
     :  OSTAT,       ! Status checking whether parameter in output cat.
     :  OQI,         ! Parameter identifier in the output catalogue.
     :  BUFLEN,      ! Length of BUFFER (excl. trail. blanks).
     :  LQNAME       !   "    "  QNAME  ( "  .   "  .   "   ).
      CHARACTER
     :  QNAME*(CAT__SZCMP),    ! Name.
     :  QUNITS*(CAT__SZUNI),   ! Units.
     :  QXTFMT*(CAT__SZEXF),   ! External format.
     :  QCOMM*(CAT__SZCOM),    ! Comments.
     :  QVALUE*(CAT__SZVAL),   ! Value.
     :  BUFFER*75              ! Output buffer.
      LOGICAL
     :  QPRFDS       ! Preferential display flag.
      DOUBLE PRECISION
     :  QDATE        ! Modification date.
*.

      IF (STATUS .EQ. SAI__OK) THEN

*
*       Copy each of the parameters in the input catalogue.

         MORE = .TRUE.
         QCOUNT = 0

         DO WHILE (MORE)

*
*          Attempt to obtain an identifier for the next parameter in the
*          input catalogue, and proceed if ok.

            QCOUNT = QCOUNT + 1

            CALL CAT_TNDNT (CIIN, CAT__QITYP, QCOUNT, QIINC, STATUS)

            IF (STATUS .EQ. CAT__OK  .AND.  QIINC .NE. CAT__NOID) THEN

*
*             Inquire the values of all the attributes for this 
*             parameter.

               CALL CAT_PINQ (QIINC, 10, QCI, QNAME, QDTYPE, QCSIZE, 
     :           QDIMS, QSIZEA, QUNITS, QXTFMT, QPRFDS, QCOMM, QVALUE, 
     :           QDATE, STATUS)

*
*             Determine whether the output catalogue already contains
*             a parameter (or column) of the given name.  Proceed if
*             it does not; otherwise issue a warning.  (Note: CAT_TIDNT
*             returns a bad status if the output catalogue does not
*             contain the parameter).

               OSTAT = SAI__OK
               CALL CAT_TIDNT (CIOUT, QNAME, OQI, OSTAT)

               IF (OSTAT .NE. SAI__OK) THEN

*
*                Annul the error generated by CAT_TIDNT.

                  CALL ERR_ANNUL (OSTAT)

*
*                Attempt to create a corresponding parameter in the output
*                catalogue.

                  CALL CAT_PNEW0 (CIOUT, CAT__QITYP, QNAME, QDTYPE,
     :              QIOUTC, STATUS)

*
*                Set the attributes of this parameter to correspond to the
*                input parameter.  Note that only those attributes which
*                can vary in a SCAR/ADC catalogue are set.

                  CALL CAT_TATTI (QIOUTC, 'CSIZE', QCSIZE, STATUS)
                  CALL CAT_TATTC (QIOUTC, 'UNITS', QUNITS, STATUS)
                  CALL CAT_TATTC (QIOUTC, 'EXFMT', QXTFMT, STATUS)
                  CALL CAT_TATTC (QIOUTC, 'COMM', QCOMM, STATUS)
                  CALL CAT_TATTC (QIOUTC, 'VALUE', QVALUE, STATUS)

               ELSE
                  BUFFER = ' '
                  BUFLEN = 0

                  CALL CHR_PUTC ('Parameter ', BUFFER, BUFLEN)

                  IF (QNAME .NE. ' ') THEN
                     LQNAME = CHR_LEN(QNAME)
                     CALL CHR_PUTC (QNAME(1 : LQNAME), BUFFER, BUFLEN)
                  ELSE
                     CALL CHR_PUTC ('<blank>', BUFFER, BUFLEN)
                  END IF

                  CALL CHR_PUTC (' has been modified.', BUFFER, BUFLEN)

                  CALL CAP_WARN (.TRUE., ' ', BUFFER(1 : BUFLEN),
     :              STATUS)

               END IF

            ELSE

*
*             Either an error has occurred or the last parameter has 
*             been accessed from the input catalogue; set the
*             termination status.

               MORE = .FALSE.
            END IF

*
*          Set the termination flag if any error has occurred.

            IF (STATUS .NE. SAI__OK) THEN
               MORE = .FALSE.
            END IF

         END DO

      END IF

      END
