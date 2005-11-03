/*
*  Name:
*     ndg.c

*  Purpose:
*     Implement the C interface to the ADAM NDG library.

*  Description:
*     This module implements C-callable wrappers for the public ADAM
*     routines in the NDG library. The interface to these wrappers
*     is defined in ndg.h.

*  Notes:
*     - Given the size of the NDG library, providing a complete C
*     interface is probably not worth the effort. Instead, I suggest that 
*     people who want to use NDG from C extend this file (and
*     ndg.h) to include any functions which they need but which are
*     not already included.

*  Authors:
*     DSB: David S Berry
*     TIMJ: Tim Jenness
*     {enter_new_authors_here}

*  History:
*     30-SEP-2005 (DSB):
*        Original version.
*     02-NOV-2005 (TIMJ):
*        Port from GRP
*     {enter_further_changes_here}
*/

/* Header files. */
/* ============= */
#include "f77.h" 
#include "sae_par.h"
#include "par_par.h"
#include "star/grp.h"
#include "ndg.h"

/* Wrapper function implementations. */
/* ================================= */


F77_SUBROUTINE(ndg_assoc)( CHARACTER(PARAM), LOGICAL(VERB), INTEGER(IGRP), INTEGER(SIZE), LOGICAL(FLAG), INTEGER(STATUS) TRAIL(PARAM) );

void ndgAssoc( char * param, int verb, Grp ** igrp, int *size, int * flag, int *status 
){
   DECLARE_INTEGER(IGRP);
   DECLARE_INTEGER(SIZE);
   DECLARE_INTEGER(STATUS);
   DECLARE_LOGICAL(VERB);
   DECLARE_LOGICAL(FLAG);
   DECLARE_CHARACTER(PARAM, PAR__SZNAM);

   /* If *igrp is NULL we need to create a new structure */
   if (*igrp == NULL) {
     *igrp = grpInit( status );
   }
   IGRP = grp1Getid(*igrp, status );
   if ( *status != SAI__OK ) return;

   F77_EXPORT_LOGICAL( verb, VERB );
   F77_EXPORT_CHARACTER( param, PARAM, PAR__SZNAM );
   F77_EXPORT_INTEGER( *status, STATUS );

   F77_CALL(ndg_assoc)( CHARACTER_ARG(PARAM), LOGICAL_ARG(&VERB),
			INTEGER_ARG(&IGRP),
                        INTEGER_ARG(&SIZE), LOGICAL_ARG(&FLAG),
                        INTEGER_ARG(&STATUS) TRAIL_ARG(PARAM) );

   F77_IMPORT_INTEGER( SIZE, *size );
   F77_IMPORT_LOGICAL( FLAG, *flag );
   F77_IMPORT_INTEGER( STATUS, *status );
   grp1Setid( *igrp, IGRP, status );

   return;
}


F77_SUBROUTINE(ndg_creat)( CHARACTER(PARAM), INTEGER(IGRP0), INTEGER(IGRP), INTEGER(SIZE), LOGICAL(FLAG), INTEGER(STATUS) TRAIL(PARAM) );

void ndgCreat( char * param, Grp *igrp0, Grp ** igrp, int *size, int * flag, int *status 
){
   DECLARE_INTEGER(IGRP0);
   DECLARE_INTEGER(IGRP);
   DECLARE_INTEGER(SIZE);
   DECLARE_INTEGER(STATUS);
   DECLARE_LOGICAL(FLAG);
   DECLARE_CHARACTER(PARAM, PAR__SZNAM);

   /* If *igrp is NULL we need to create a new structure */
   if (*igrp == NULL) {
     *igrp = grpInit( status );
   }
   IGRP = grp1Getid(*igrp, status );
   IGRP0 = grp1Getid( igrp0, status );
   if ( *status != SAI__OK ) return;

   F77_EXPORT_CHARACTER( param, PARAM, PAR__SZNAM );
   F77_EXPORT_INTEGER( *status, STATUS );

   F77_CALL(ndg_creat)( CHARACTER_ARG(PARAM), INTEGER_ARG(&IGRP0),
			INTEGER_ARG(&IGRP),
                        INTEGER_ARG(&SIZE), LOGICAL_ARG(&FLAG),
                        INTEGER_ARG(&STATUS) TRAIL_ARG(PARAM) );

   F77_IMPORT_INTEGER( SIZE, *size );
   F77_IMPORT_LOGICAL( FLAG, *flag );
   
   F77_IMPORT_INTEGER( STATUS, *status );
   grp1Setid( *igrp, IGRP, status );

   return;
}
