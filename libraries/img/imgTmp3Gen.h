/*
 *  Name:
 *     imgTmp3Gen

 *  Purpose:
 *     Creates a temporary input 3-D image using a specific type.

 *  Language:
 *     ANSI C

 *  Invocation:
 *     imgTmp3[x]( param, nx, ny, nz, ip, status )

 *  Description:
 *     This C function sets up the required arguments and calls the
 *     Fortran subroutine img_tmp3[x].
 *     On return, values are converted back to C form if necessary.
 *
 *     This version is the generic form for the float, double, int,
 *     short, unsigned short, char and unsigned char versions. Just
 *     include this in the appropriate stub after setting the 
 *     values of the macros:
 *
 *        IMG_F77_TYPE   = (r|d|l|i|w|uw|b|ub)
 *        IMG_FULL_C_TYPE   = (float|double|short etc.)
 *        IMG_SHORT_C_TYPE   = (F|D|I|S|US|B|UB)
 *
 *     The IMG_F77_TYPE essentially names the fortran version of this
 *     routine to invoke.

 *  Arguments:
 *     param = char * (Given)
 *        Parameter name (case insensitive).
 *     nx = int * (Given)
 *        Size of the first dimension of the image (in pixels).
 *     ny = int * (Given)
 *        Size of the second dimension of the image (in pixels).
 *     nz = int * (Given)
 *        Size of the third dimension of the image (in pixels).
 *     ip = ? ** (Returned)
 *        Pointer to the image data.
 *     status = int * (Given and Returned)
 *        The global status.

 *  Authors:
 *     The orginal version was generated automatically from the
 *     Fortran source of img_inr by the Perl script fcwrap.
 *     PDRAPER: Peter W. Draper (STARLINK - Durham University)
 *     {enter_new_authors_here}

 *  History:
 *     17-May-1996 (fcwrap):
 *        Original version
 *     28-May-1996 (PDRAPER):
 *        Added code to handle pointer arrays correctly. Made into
 *        generic include file. 
 *     10-JUN-1996 (PDRAPER):
 *        Changed to use more C-like names.
 *     {enter_changes_here}

 *-
 */


IMG_TMP3( IMG_F77_TYPE ) ( CHARACTER(param),
                           INTEGER(nx),                           
                           INTEGER(ny),
                           INTEGER(nz),
                           POINTER_ARRAY(ip),
                           INTEGER(status)
                           TRAIL(param) );

IMGTMP3( IMG_SHORT_C_TYPE ) ( char *param,
                              int nx,
                              int ny,
                              int nz,
                              IMG_FULL_C_TYPE **ip,
                              int *status ) 
{
  DECLARE_CHARACTER_DYN(fparam);
  int nparam;
  int i;
  F77_POINTER_TYPE *fip;
  
  F77_CREATE_CHARACTER(fparam,strlen( param ));
  cnf_exprt( param, fparam, fparam_length );
  
  /*  Count the number of input parameters and create enough space for
      the corresponding Fortran pointers */
  nparam = img1CountParams( param, status );
  fip = (F77_POINTER_TYPE *) malloc( nparam * sizeof(F77_POINTER_TYPE) );
  
  IMGTMP3_CALL( IMG_F77_TYPE ) ( CHARACTER_ARG(fparam),
                                 INTEGER_ARG(&nx),
                                 INTEGER_ARG(&ny),
                                 INTEGER_ARG(&nz),
                                 POINTER_ARRAY_ARG(fip),
                                 INTEGER_ARG(status)
                                 TRAIL_ARG(fparam) );
  
  /*  Now copy the addresses back to to C pointers */
  for( i=0; i < nparam; i++ ) { 
    ip[i] = (IMG_FULL_C_TYPE *) fip[i];
  }
  free( (void *)fip );
  F77_FREE_CHARACTER(fparam);

  return;
}
/* $Id$ */
