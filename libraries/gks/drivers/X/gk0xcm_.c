/*
 * RAL GKS SYSTEM
 *
 * gk0xcm_: Colour manager for the Sun workstation using WW.
 *
 * Type of Routine:  Part of WORKSTATION DRIVER
 * Author:           TAW
 *
 * Copyright (C) SERC 1987
 *
 * Maintenance Log:
 *
 *  31/03/87  TAW   Created.
 *  22/03/87  PJWR  Redocumented and extended.
 *  14/07/87  PJWR  IS: Changed error 2006 to error -2006.
 *  08/09/87  PJWR  Corrected description of parameter 'range'.
 *  15/09/87  PJWR  Modified handling of monochrome workstations to
 *                  reflect changes to the underlying software.
 *  22/09/87  PJWR  Changed from editing single entries to getting old
 *                  colourmap,  editing and reloading.  Parameter 'range'
 *                  no longer needed - size of colour table is read from
 *                  workstation description table.  Tweaking of SunView
 *                  foreground colour to prevent resetting by SunView
 *                  added and yet more changes to monochrome handling.
 *  08/12/87  PJWR  Changed colour mapping so GKS uses SunView conventions.
 *  10/08/88  TAW   Copied from ../sun/gk9scm_.c.
 *  02/11/88  TAW   Took out tweaking as not needed in X.
 */

#include <stdio.h>
#include <wwinfo.h>			  /* For WW */
#include "../../system/include/f77_type.h"  /* For FORTRAN 77 type matching */
#include "../../system/include/gkerr.h"	  /* For GKS error reporting */
#include "../../system/include/gkdt.h"	  /* Needed by what follows */
#include "../../system/include/gkwca.h"	  /* For workstation index */
#include "../../system/include/gkwdt.h"	  /* For size of colour table */

/*
 * Errors:
 *
 *  -2006  Value of internal enumerated type is invalid
 */

f77_integer gk0xcm_(flag, index, red, green, blue)
  f77_integer *flag;			/* Get or set colour (In) */
  f77_integer *index;			/* Which colour to access (In) */
  f77_real    *red;			/* Red component (In/Out) */
  f77_real    *green;			/* Green component (In/Out) */
  f77_real    *blue;			/* Blue component (In/Out) */
{
  char
    *calloc();				/* For allocating colourmap space */

  f77_integer
    gk0xcc_();				/* Maps GKS to SunView colour indices */

  f77_real
    intensity;				/* For monochrome intensity */

  unsigned char
    *cred,				/* For passing parameters to gk0xcorep() */
    *cgreen,
    *cblue;

  int
    colours = (int)gkywdt_.kpci[gkywca_.kwkix-1],	/* Size of colourmap */
    lindex = (int)gk0xcc_(index);			/* SunView index */

  /* Get space for RGB data and get current colourmap */

  cred = (unsigned char *)calloc((unsigned)(3 * colours),
				 (unsigned)sizeof(unsigned char));
  cgreen = cred + colours;
  cblue = cgreen + colours;

  (void)gk0xcorep(ddbm,cred,cgreen,cblue,sizeof(char),0,colours,COGET);

  /*
   * Now either set colour and reload colourmap or return RGB intensity
   * required according to the flag supplied.
   */

  if(*flag == COSET)
    if(colours == 2)			/* Monochrome workstation */
    {
      /* Calculate overall intensity */

      intensity = (*red * 0.3) + (*green * 0.59) + (*blue * 0.11);

      /*
       * If the intensity of the foreground is > 0.5,  we set up a black
       * background and a white foreground and vice versa.
       */

      if(intensity > 0.5 && lindex == 1 || intensity <= 0.5 && lindex == 0)
      {
	cred[0] = cgreen[0] = cblue[0] = 0x00;
	cred[1] = cgreen[1] = cblue[1] = 0xff;
      }
      else
      {
	cred[0] = cgreen[0] = cblue[0] = 0xff;
	cred[1] = cgreen[1] = cblue[1] = 0x00;
      }

      (void)gk0xcorep(ddbm,cred,cgreen,cblue,1,0,2,COSET);
    }
    else				/* Colour workstation */
    {
      /*
       * Reduce the intensities of the RGB components to discrete values
       * and edit the colourmap entry.
       */

      *(cred + lindex)   = (unsigned char)(*red * 255);
      *(cgreen + lindex) = (unsigned char)(*green * 255);
      *(cblue + lindex)  = (unsigned char)(*blue * 255);

      /* Reload the colourmap */

      (void)gk0xcorep(ddbm,cred,cgreen,cblue,1,0,colours,COSET);
    }
  else if(*flag == COGET)
  {
    *red   = (f77_real)*(cred + lindex) / 255.0;
    *green = (f77_real)*(cgreen + lindex) / 255.0;
    *blue  = (f77_real)*(cblue + lindex) / 255.0;
  }
  else
    gkyerr_.kerror = -2006;

  /* Free the RGB arrays */
  (void)free((char *)cred);

  return ((f77_integer)0);
}
