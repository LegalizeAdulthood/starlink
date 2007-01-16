
/*
*+
*  Name:
*     smf_rebincube

*  Purpose:
*     Paste a supplied 3D array into an existing cube.

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     C function

*  Invocation:
*     smf_rebincube( smfData *data, int index, int size, AstFrameSet *swcsout, 
*                    AstFrame *ospecfrm, AstMapping *ospecmap, Grp *detgrp,
*                    int moving, dim_t lbnd_out[ 3 ], dim_t ubnd_out[ 3 ], 
*                    int spread, const double params[], int genvar, 
*                    float *data_array, float *var_array, double *wgt_array, 
*                    int *work_array, int *status );

*  Arguments:
*     data = smfData * (Given)
*        Pointer to the input smfData structure.
*     index = int (Given)
*        Index of the current input file within the group of input files.
*     size = int (Given)
*        Index of the last input file within the group of input files.
*     swcsout = AstFrameSet * (Given)
*        A FrameSet in which the current Frame respresents 2D spatial GRID 
*        coords in the output, and the base Frame represents 2D sky
*        coords in the output. Note the unusual order of base and current 
*        Frame. If "Moving" is non-zero, the sky coords should be offsets
*        from the first base pointing position (which should be stored in 
*        SkyRef attribute of the SkyFrame).
*     ospecfrm = AstFrame * (Given)
*        Pointer to the SpecFrame within the current Frame of the output WCS 
*        Frameset.
*     ospecmap = AstMapping * (Given)
*        Pointer to the Mapping from the SpecFrame to the third GRID axis 
*        within the current Frame of the output WCS Frameset.
*     detgrp = Grp * (Given)
*        A Group containing the names of the detectors to be used. All
*        detectors will be used if this group is empty.
*     moving = int (Given)
*        A flag indicating if the telescope is tracking a moving object. If 
*        so, each time slice is shifted so that the position specified by 
*        TCS_AZ_BC1/2 is mapped on to the same pixel position in the
*        output cube.
*     lbnd_out = dim_t [ 3 ] (Given)
*        The lower pixel index bounds of the output cube.
*     ubnd_out = dim_t [ 3 ] (Given)
*        The upper pixel index bounds of the output cube.
*     spread = int (Given)
*        Specifies the scheme to be used for dividing each input data value 
*        up amongst the corresponding output pixels. See docs for astRebinSeq
*        (SUN/211) for the allowed values.
*     params = const double[] (Given)
*        An optional pointer to an array of double which should contain any
*        additional parameter values required by the pixel spreading scheme. 
*        See docs for astRebinSeq (SUN/211) for further information. If no 
*        additional parameters are required, this array is not used and a
*        NULL pointer may be given. 
*     genvar = int (Given)
*        Indicates how the output variances should be calculated: 
*           0 = do not calculate any output variances
*           1 = use spread of input data values
*           2 = use system noise temperatures
*     data_array = float * (Given and Returned)
*        The data array for the output cube. This is updated on exit to
*        include the data from the supplied input NDF.
*     var_array = float * (Given and Returned)
*        An array in which to store the variances for the output cube if
*        "genvar" is not zero (the supplied pointer is ignored if "genvar" is 
*        zero). The supplied array is update on exit to include the data from 
*        the supplied input NDF. If "spread" is AST__NEAREST, then this array 
*        should be big enough to hold a single spatial plane from the output 
*        cube (all planes will have the same variance and so only one plane 
*        need be calculated). For other values of "spread", the "var_array" 
*        array should be the same shape and size as the output data array.
*     wgt_array = double * (Given and Returned)
*        An array in which to store the relative weighting for each pixel in 
*        the output cube. The supplied array is update on exit to include the 
*        data from the supplied input NDF. If "spread" is AST__NEAREST, then 
*        this array should be big enough to hold a single spatial plane from 
*        the output cube (all planes will have the same weight and so only one 
*        plane need be calculated). For other values of "spread", the 
*        "wgt_array" array should be twice the length of "data_array".
*     work_array = int * (Given and Returned)
*        A work array, which is updated on exit to include the supplied input 
*        NDF. Only used if "genvar" is 1 and "spread" is AST__NEAREST. It
*        should be big enough to hold a single spatial plane from the output 
*        cube.
*     status = int * (Given and Returned)
*        Pointer to the inherited status.

*  Description:
*     The data array of the supplied input NDF is added into the existing
*     contents of the output data array, and the variance and weights
*     arrays are updated correspondingly.
*
*     Note, few checks are performed on the validity of the input data
*     files in this function, since they have already been checked within
*     smf_cubebounds.

*  Authors:
*     David S Berry (JAC, UClan)
*     {enter_new_authors_here}

*  History:
*     20-SEP-2006 (DSB):
*        Initial version.
*     13-OCT-2006 (DSB):
*        Changed to get the input spectral WCS from the WCS FrameSet rather 
*        than the FITS header.
*     6-NOV-2006 (DSB):
*        Added "detgrp" parameter.
*     21-NOV-2006 (DSB):
*        Only create variance values if the output pixel value is formed
*        from more than 1 detector sample.
*     23-NOV-2006 (DSB):
*        - Allow astRebinSeq to be used with any pixel spreading method.
*        - Take account of 1/sqrt(N) reduction in output standard deviations.
*     28-NOV-2006 (DSB):
*        Allow "var_array" to be NULL.
*     29-NOV-2006 (DSB):
*        Correct use of "wgt_array" if "var_array" is NULL.
*     13-DEC-2006 (DSB):
*        Added "genvar" argument and allow output variances to be
*        calculated on the basis of Tsys.
*     19-DEC-2006 (TIMJ):
*        In some broken data FFT_WIN is undef. Assume truncate.
*     21-DEC-2006 (DSB):
*        Restructured to make moving targets work correctly.
*     15-JAN-2007 (DSB):
*        Restructured to use 2D weights and variance arrays for nearest
*        neighbour re-binning.
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2006 Particle Physics and Astronomy Research Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public
*     License along with this program; if not, write to the Free
*     Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
*     MA 02111-1307, USA

*  Bugs:
*     {note_any_bugs_here}
*-
*/

#include <stdio.h>
#include <math.h>

/* Starlink includes */
#include "ast.h"
#include "mers.h"
#include "sae_par.h"
#include "prm_par.h"
#include "star/ndg.h"

/* SMURF includes */
#include "libsmf/smf.h"

/* Returns nearest integer to "x" */
#define NINT(x) ( ( x > 0 ) ? (int)( x + 0.5 ) : (int)( x - 0.5 ) )

#define FUNC_NAME "smf_rebincube"

void smf_rebincube( smfData *data, int index, int size, AstFrameSet *swcsout,
                    AstFrame *ospecfrm, AstMapping *ospecmap, Grp *detgrp, 
                    int moving, int lbnd_out[ 3 ], int ubnd_out[ 3 ], 
                    int spread, const double params[], int genvar,
                    float *data_array, float *var_array, double *wgt_array, 
                    int *work_array, int *status ){

/* Local Variables */
   AstCmpMap *fmap = NULL;     /* Mapping from spectral grid to topo freq Hz */
   AstCmpMap *ssmap = NULL;    /* Input GRID->output GRID Mapping for spectral axis */
   AstFitsChan *fc = NULL;     /* FitsChan used to get spectral WCS from input */           
   AstFrame *specframe = NULL; /* SpecFrame in input WCS */
   AstFrame *specframe2 = NULL;/* Temporary copy of SpecFrame in input WCS */
   AstFrameSet *fs = NULL;     /* WCS FramesSet from input */           
   AstFrameSet *swcsin = NULL; /* Spatial WCS FrameSet for current time slice */
   AstMapping *fsmap = NULL;   /* WCS->GRID Mapping from input WCS FrameSet */
   AstMapping *specmap = NULL; /* GRID->Spectral Mapping for current input file */
   char *fftwin = NULL;        /* Name of FFT windowing function */
   const char *name;           /* Pointer to current detector name */
   const double *tsys;         /* Pointer to Tsys value for first detector */
   dim_t iv;                   /* Vector index into output 3D array */
   dim_t iv0;                  /* Vector index into 2D array */
   dim_t nel;                  /* No. of pixels in output */
   dim_t nxy;                  /* Number of pixels in one output xy plane */
   double *ipw = NULL;         /* Pointer to weights arrays */
   double *spectab = NULL;     /* Workspace for spectral output grid positions */
   double *xin = NULL;         /* Workspace for detector input grid positions */
   double *xout = NULL;        /* Workspace for detector output grid positions */
   double *yin = NULL;         /* Workspace for detector input grid positions */
   double *yout = NULL;        /* Workspace for detector output grid positions */
   double at;                  /* Frequency at which to take the gradient */
   double coff;                /* Ratio of "off source" to "on source" integration times */
   double dnew;                /* Channel width in Hz */
   double d2sum;               /* Sum of squared data values in output spectrum */
   double fcon;                /* Variance factor for whole file */
   double k;                   /* Back-end degradation factor */
   double tcon;                /* Variance factor for whole time slice */
   double wgt;                 /* Input sample weight */
   float *detwork = NULL;      /* Work array holding data samples for 1 slice/channel */
   float *ipv = NULL;          /* Pointer to input variances values */
   float *pdata = NULL;        /* Pointer to next input data value */
   float *varwork = NULL;      /* Work array holding variances for 1 slice/channel */
   int ast_flags;              /* Flags to use with astRebinSeq */
   int dim[ 3 ];               /* Output array dimensions */
   int found;                  /* Was current detector name found in detgrp? */
   int ibasein;                /* Index of base Frame in input WCS FrameSet */
   int ichan;                  /* Index of current channel */
   int idet;                   /* detector index */
   int itime;                  /* Index of current time slice */
   int ix;                     /* Output grid index on axis 1 */
   int iy;                     /* Output grid index on axis 2 */
   int iz;                     /* Output grid index on axis 3 */
   int lbnd_in[ 2 ];           /* Lower input bounds on receptor axis */
   int ldim[ 3 ];              /* Output array lower GRID bounds */
   int nchan;                  /* Number of spectral channels */
   int ngoodchan;              /* Number of usable spectral channels */
   int pixax[ 3 ];             /* Pixel axis indices */
   int specax;                 /* The index of the input spectral axis */
   int ubnd_in[ 2 ];           /* Upper input bounds on receptor axis */
   int use_ast;                /* Use astRebinSeq to do the rebinning? */
   smfHead *hdr = NULL;        /* Pointer to data header for this time slice */

/* Check the inherited status. */
   if( *status != SAI__OK ) return;

/* Begin an AST context.*/
   astBegin;

/* Set a flag indicating if hard-wired code is to used instead of the 
   astRebinSeq function. */
   use_ast = ( spread != AST__NEAREST );

/* Store a pointer to the input NDFs smfHead structure. */
   hdr = data->hdr;

/* Store the dimensions of the output array. */
   dim[ 0 ] = ubnd_out[ 0 ] - lbnd_out[ 0 ] + 1;
   dim[ 1 ] = ubnd_out[ 1 ] - lbnd_out[ 1 ] + 1;
   dim[ 2 ] = ubnd_out[ 2 ] - lbnd_out[ 2 ] + 1;

/* Fill an array with the lower grid index bounds of the output. */
   ldim[ 0 ] = 1;
   ldim[ 1 ] = 1;
   ldim[ 2 ] = 1;

/* We want a description of the spectral WCS axis in the input file. If 
   the input file has a WCS FrameSet containing a SpecFrame, use it,
   otherwise we will obtain it from the FITS header later. NOTE, if we knew 
   that all the input NDFs would have the same spectral axis calibration, 
   then the spectral WCS need only be obtained from the first NDF. However, 
   in the general case, I presume that data files may be combined that use 
   different spectral axis calibrations, and so these differences need to 
   be taken into account. */
   if( hdr->tswcs ) {   
      fs = astClone( hdr->tswcs );
   
/* The first axis should be a SpecFrame. See if this is so. If not annul
   the specframe pointer. */
      specax = 1;
      specframe = astPickAxes( fs, 1, &specax, NULL );
      if( !astIsASpecFrame( specframe ) ) specframe = astAnnul( specframe );
   } 

/* If the above did not yield a SpecFrame, use the FITS-WCS headers in the 
   FITS extension of the input NDF. Take a copy of the FITS header (so that 
   the contents of the header are not changed), and then read a FrameSet 
   out of it. */
   if( !specframe ) {
      fc = astCopy( hdr->fitshdr );
      astClear( fc, "Card" );
      fs = astRead( fc );

/* Extract the SpecFrame that describes the spectral axis from the current 
   Frame of this FrameSet. This is assumed to be the third WCS axis (NB
   the different axis number). */
      specax = 3;
      specframe = astPickAxes( fs, 1, &specax, NULL );
   }

/* Split off the 1D Mapping for this single axis from the 3D Mapping for
   the whole WCS. This results in "specmap" holding the Mapping from 
   SpecFrame value to GRID value. */
   fsmap = astGetMapping( fs, AST__CURRENT, AST__BASE );
   astMapSplit( fsmap, 1, &specax, pixax, &specmap );

/* Invert the Mapping for the spectral axis so that it goes from input GRID
   coord to spectral coord. */
   astInvert( specmap );

/* Get a Mapping that converts values in the input spectral system to the 
   corresponding values in the output spectral system. */
   fs = astConvert( specframe, ospecfrm, "" );

/* Concatenate these Mappings with the supplied spectral Mapping to get 
   a Mapping from the input spectral grid axis (pixel axis 1) to the
   output spectral grid axis (pixel axis 3). Simplify the Mapping. */
   ssmap = astCmpMap( astCmpMap( specmap, astGetMapping( fs, AST__BASE,
                                                         AST__CURRENT ),
                                 1, "" ), 
                      ospecmap, 1, "" );
   ssmap = astSimplify( ssmap );

/* Create a table with one element for each channel in the input array,
   holding the index of the nearest corresponding output pixel. */
   nchan = (data->dims)[ 0 ];
   spectab = astMalloc( sizeof( double )*nchan );
   if( spectab ) {
      for( ichan = 0; ichan < nchan; ichan++ ) spectab[ ichan ] = ichan + 1;
      astTran1( ssmap, nchan, spectab, 1, spectab );
      for( ichan = 0; ichan < nchan; ichan++ ) {
         if( spectab[ ichan ] != AST__BAD ) {
            iz = floor( spectab[ ichan ] + 0.5 );
            if( iz >= 1 && iz <= dim[ 2 ] ) {
               spectab[ ichan ] = iz;
            } else {
               spectab[ ichan ] = 0;
            }             
         } else {
            spectab[ ichan ] = 0;
         }
      }
   }

/* Store the number of elements in an XY plane of the output. */
   nxy = dim[ 0 ]*dim[ 1 ];

/* Store the total number of elements in the output. */
   nel = nxy*dim[ 2 ];

/* If this is the first pass through this file, initialise the arrays. */
   if( index == 1 ){

/* Initialise the output cube data array to zero. */
      for( iv = 0; iv < nel; iv++ ) data_array[ iv ] = 0.0;

/* Other array lengths depend on whether AST is being used to do the
   rebinning. For AST rebinning, also initialisation the flags for
   astRebinSeq (we set flags to zero to indicate that the arrays have
   been initialised). */
      if( use_ast ){
         for( iv = 0; iv < 2*nel; iv++ ) wgt_array[ iv ] = 0.0;
         if( genvar ) {
            for( iv = 0; iv < nel; iv++ ) var_array[ iv ] = 0.0;
         }

         ast_flags = 0;

      } else {
         for( iv0 = 0; iv0 < nxy; iv0++ ) wgt_array[ iv0 ] = 0.0;
         if( genvar ) {
            for( iv0 = 0; iv0 < nxy; iv0++ ) var_array[ iv0 ] = 0.0;
            for( iv0 = 0; iv0 < nxy; iv0++ ) work_array[ iv0 ] = 0;
         }
      }
   }

/* Allocate work arrays big enough to hold the coords of all the detectors in 
   the current input file. */
   xin = astMalloc( (data->dims)[ 1 ] * sizeof( double ) );
   yin = astMalloc( (data->dims)[ 1 ] * sizeof( double ) );
   xout = astMalloc( (data->dims)[ 1 ] * sizeof( double ) );
   yout = astMalloc( (data->dims)[ 1 ] * sizeof( double ) );

/* Allocate work array to hold all the detector values and input variances for 
   a single time slice of a single spectral channel. */
   if( use_ast ) {
      detwork = astMalloc( (data->dims)[ 1 ] * sizeof( float ) );
      if( genvar == 2 ) varwork = astMalloc( (data->dims)[ 1 ] * sizeof( float ) );
   }

/* Initialise a string to point to the name of the first detector for which 
   data is available */
   name = hdr->detname;

/* Loop round all detectors for which data is available. */
   for( idet = 0; idet < (data->dims)[ 1 ]; idet++ ) {

/* Store the GRID coord of this detectors. */
      xin[ idet ] = idet + 1.0;
      yin[ idet ] = 1.0;

/* If a group of detectors to be used was supplied, search the group for
   the name of the current detector. If not found, set the GRID coords bad. 
   This will cause the detector to be excluded. */
      if( detgrp ) {    
         grpIndex( name, detgrp, 1, &found, status );
         if( !found ) {
            xin[ idet ] = AST__BAD;
            yin[ idet ] = AST__BAD;
         }
      }

/* Move on to the next available detector name. */
      name += strlen( name ) + 1;
   }

/* If output variances are being calculated on the basis of Tsys values
   in the input, find the constant factor associated with the current input
   file. This is the squared backend degradation factor, divided by the
   noise bandwidth. */
   fcon = AST__BAD;
   if( genvar == 2 ) {

/* Get the required FITS headers, checking they were found. */
      if( astGetFitsF( hdr->fitshdr, "BEDEGFAC", &k ) &&
          astGetFitsS( hdr->fitshdr, "FFT_WIN", &fftwin ) ){

/* Get a Mapping that converts values in the input spectral system to
   topocentric frequency in Hz, and concatenate this Mapping with the
   Mapping from input GRID coord to the input spectral system. The result 
   is a Mapping from input GRID coord to topocentric frequency in Hz. */
         specframe2 = astCopy( specframe );
         astSet( specframe2, "system=freq,stdofrest=topo,unit=Hz" );
         fmap = astCmpMap( specmap, astGetMapping( astConvert( specframe, 
                                                               specframe2, 
                                                               "" ),
                                                   AST__BASE, AST__CURRENT ),
                           1, "" );

/* Differentiate this Mapping at the mid channel position to get the width
   of an input channel in Hz. */
         at = 0.5*nchan;
         dnew = astRate( fmap, &at, 1, 1 );

/* Modify the channel width to take account of the effect of the FFT windowing 
   function. Allow undef value because FFT_WIN for old data had a broken value 
   in hybrid subband modes. */
         if( dnew != AST__BAD ) {
            dnew = fabs( dnew );

            if( !strcmp( fftwin, "truncate" ) ) {
               dnew *= 1.0;

            } else if( !strcmp( fftwin, "hanning" ) ) {
               dnew *= 1.5;

	    } else if( !strcmp( fftwin, "<undefined>" ) ) {
	      /* Deal with broken data - make an assumption */
 	       dnew *= 1.0;

            } else if( *status == SAI__OK ) {
               *status = SAI__ERROR;
               msgSetc( "W", fftwin );
               errRep( FUNC_NAME, "FITS header FFT_WIN has unknown value "
                       "'^W' (programming error).", status );
            }

/* Form the required constant. */
            fcon = k*k/dnew;  
         }        
      }
   }

/* Store a pointer to the next input data value to use. */
   pdata = (data->pntr)[ 0 ];

/* Loop round all time slices in the input NDF. */
   for( itime = 0; itime < (data->dims)[ 2 ] && *status == SAI__OK; itime++ ) {

/* Get a FrameSet describing the spatial coordinate systems associated with 
   the current time slice of the current input data file. The base frame in 
   the FrameSet will be a 2D Frame in which axis 1 is detector number and 
   axis 2 is unused. The current Frame will be a SkyFrame (the SkyFrame 
   System may be any of the JCMT supported systems). The Epoch will be
   set to the epoch of the time slice. */
      smf_tslice_ast( data, itime, 1, status );
      swcsin = hdr->wcs;

/* If output variances are being calculated on the basis of Tsys values
   in the input, find the constant factor associated with the current
   time slice. */
      tcon = AST__BAD;
      if( fcon != AST__BAD ) {
         if( hdr->state->acs_no_prev_ref != VAL__BADI &&
             hdr->state->acs_no_next_ref != VAL__BADI &&
             hdr->state->acs_no_ons != VAL__BADI &&
             hdr->state->acs_exposure != VAL__BADR &&
             hdr->state->acs_no_ons > 0 ) {

            coff = (double)( hdr->state->acs_no_prev_ref +
                             hdr->state->acs_no_next_ref )/
                   (double) hdr->state->acs_no_ons;
            tcon = fcon*( 1.0 + coff )/( coff*hdr->state->acs_exposure );

/* Get a pointer to the start of the Tsys values for this time slice. */
            tsys = hdr->tsys + hdr->ndet*itime;
         }
      }

/* If the target is moving, set the input WCS FrameSet to represent Az,El
   offsets from the base pointing position for the current time slice. */
      if( moving ) {
         astSet( swcsin, "System=AZEL" );
         astSetD( swcsin, "SkyRef(1)", hdr->state->tcs_az_bc1 );
         astSetD( swcsin, "SkyRef(2)", hdr->state->tcs_az_bc2 );
         astSetC( swcsin, "SkyRefIs", "Origin" );
         astSetI( swcsin, "AlignOffset", 1 );
      }

/* We now align the input and output WCS FrameSets. astConvert finds the
   Mapping between the current Frames of the two FrameSets (the two 
   SkyFrames in this case), but we want the Mapping between the the two
   base Frames (input GRID to output GRID). So we invert the input WCS
   FrameSet (the output WCS FrameSet has already been inverted). */
      astInvert( swcsin );

/* Now use astConvert to get the Mapping from input GRID to output GRID
   coords, aligning the coordinate systems on the sky. Note the original 
   base Frame index so it can be re-instated afterwards (astConvert changes
   it to indicate the alignment Frame).*/
      ibasein = astGetI( swcsin, "Base" );
      fs = astConvert( swcsin, swcsout, "SKY" );
      fsmap = astGetMapping( fs, AST__BASE, AST__CURRENT );         
      astSetI( swcsin, "Base", ibasein );

/* Invert the input WCS FrameSet again to bring it back into its original
   state. */
      astInvert( swcsin );

/* First deal with nearest neighbour pixel spreading. This can be done
   with specialist code that is faster than astRebinSeq. */
      if( !use_ast ) {

/* Transform the positions of the detectors at the current time slice from 
   input GRID to output GRID coords. */
         astTran2( fsmap, (data->dims)[ 1 ], xin, yin, 1, xout, yout );

/* For each good position, place the input data values for a whole spectrum
   into the nearest pixel of the output array and increment the 2D weight 
   array. */
         for( idet = 0; idet < (data->dims)[ 1 ]; idet++ ) {
   
            if( xout[ idet ] != AST__BAD && yout[ idet ] != AST__BAD ) {
               ix = floor( xout[ idet ] + 0.5 ) - 1;
               iy = floor( yout[ idet ] + 0.5 ) - 1;
   
               if( ix >= 0 && ix < dim[ 0 ] && 
                   iy >= 0 && iy < dim[ 1 ] ) {
   
/* Calculate the weight to associate with the current input spectrum. This 
   is either 1.0, or the reciprocal of the input variance, based on the 
   input Tsys values. */
                  if( tcon == AST__BAD ) {
                     wgt = 1.0;

                  } else {
                     wgt = tcon*tsys[ idet ]*tsys[ idet ];
                     if( wgt > 0.0 ) {
                        wgt = 1.0/wgt;
                     } else {
                        wgt = AST__BAD;
                     }
                  } 

/* Skip to the next detector if no weight could be calculated for this
   detector. */
                  if( wgt != AST__BAD ) {

/* Update the total weight associated with the appropriate output spectrum. 
   The weight is the same for all channels in the output spectrum, and so 
   the weights array need only be a single 2D slice. */
                     iv0 = ix + dim[ 0 ]*iy;
                     wgt_array[ iv0 ] += wgt;

/* Loop round every channel, updating the output data array. */
                     for( ichan = 0; ichan < nchan; ichan++, pdata++ ) {
                        iz = spectab[ ichan ] - 1;
                        if( iz >= 0 && iz < dim[ 2 ] ) {

/* Find the vector index of the pixel within the 3D output data array
   that will receieve this input pixel. */
                           iv = iv0 + nxy*iz;

/* If any output pixel is contributed to by a bad input pixel, then set
   the output pixel bad. We need to do this because we only have a 2D array
   to store the weights in and so we cannot retain information about the
   number of bad pixels contributing to each channel. */
                           if( *pdata != VAL__BADR && 
                               data_array[ iv ] != VAL__BADR ) {
                              data_array[ iv ] += wgt*( *pdata );

/* If we are creating output variances based on the spread of input values, 
   update the variance array to include the squared input data value. The
   "wgt" value is guranteed to be 1.0 in this case, and so we do not need to
   included it. */
                              if( genvar == 1 ) {
                                 var_array[ iv0 ] += ( *pdata )*( *pdata );
                                 work_array[ iv0 ]++;
                              }

                           } else {
                              data_array[ iv ] = VAL__BADR;
                           }
                        }
                     }

                  } else {
                     pdata += nchan;
                  }
   
               } else {
                  pdata += nchan;
               }
   
            } else {
               pdata += nchan;
            }
         }

/* Now deal with cases where we are using astRebinSeq. */
      } else {

/* Store the bounds of the detector grid (the second axis is a dummy axis
   that always has the value 1). */
         lbnd_in[ 0 ] = 1;
         ubnd_in[ 0 ] = (data->dims)[ 1 ];
         lbnd_in[ 1 ] = 1;
         ubnd_in[ 1 ] = 1;

/* If required calculate the variance associated with each detector
   sample, based on the input Tsys values. */
         if( tcon != AST__BAD ) {
            for( idet = 0; idet < (data->dims)[ 1 ]; idet++ ) {
               varwork[ idet ] = tcon*tsys[ idet ]*tsys[ idet ];
            }
         }

/* Process each spectral channel in turn. */
         for( ichan = 0; ichan < nchan; ichan++, pdata++ ) {

/* Get the offset to the first pixel in the output arrays that correspond
   to the current input spectral channel. Skip this point if it is
   outside the bounds of the output array. */
            iz = spectab[ ichan ] - 1;
            if( iz >= 0 && iz < dim[ 2 ] ) { 
               iv = nxy*iz;

/* Store pointers to the variance and work arrays be used */
               if( genvar == 2 ) {
                  ipv = var_array + iv;
                  ipw = wgt_array + iv;

               } else if( genvar == 1 ) {
                  ipv = var_array + iv;
                  ipw = wgt_array + 2*iv;

               } else {
                  ipv = NULL;
                  ipw = wgt_array + iv;
               }

/* Copy the detector values for this spectral channel and time slice into
   a new array. */
               for( idet = 0; idet < (data->dims)[ 1 ]; idet++ ) {
                  detwork[ idet ] = pdata[ idet*nchan ];
               }

/* Paste this array into the plane of the output cube corresponding to
   the current spectral channel. */
               astRebinSeqF( fsmap, 0.0, 2, lbnd_in, ubnd_in, detwork, varwork,
                             spread, params, ast_flags, 0.0, 50, VAL__BADR, 
                             2, ldim, dim, lbnd_in, ubnd_in, data_array + iv, 
                             ipv, ipw );
            }
         }

/* Move "pdata" on to point at the first input element in the next
   spectral channel. */
         pdata += nchan*( (data->dims)[ 1 ] - 1 );
      }

/* For efficiency, explicitly annul the AST Objects created in this tight
   loop. */
      fsmap = astAnnul( fsmap );
      fs = astAnnul( fs );
   }

/* If this is the final pass through this function, normalise the returned
   data and variance values. */
   if( index == size ) {

/* If we have been using astRebinSeq to do the rebinning, also use
   astRebinSeq to do the normalisation. */
      if( use_ast ) {

/* Create a dummy mapping that can be used with astRebinSeq (it is not
   actually used for anything since we are not adding any more data into the
   output arrays). */
         fsmap = (AstMapping *) astUnitMap( 2, "" );

/* Process each spectral channel in turn. */
         for( ichan = 0; ichan < nchan; ichan++ ) {

/* Get the offset to the first pixel in the output arrays that correspond
   to the current input spectral channel. Skip this point if it is
   outside the bounds of the output array. */
            iz = spectab[ ichan ] - 1;
            if( iz >= 0 && iz < dim[ 2 ] ) { 
               iv = nxy*iz;

/* Store pointers to the variance and work arrays be used */
               if( genvar == 2 ) {
                  ipv = var_array + iv;
                  ipw = wgt_array + iv;

               } else if( genvar == 1 ) {
                  ipv = var_array + iv;
                  ipw = wgt_array + 2*iv;

               } else {
                  ipv = NULL;
                  ipw = wgt_array + iv;
               }

/* Normalise the data values. */
               astRebinSeqF( fsmap, 0.0, 2, lbnd_in, ubnd_in, NULL, NULL, 
                             spread, params, AST__REBINEND | ast_flags,
                             0.0, 50, VAL__BADR, 2, ldim, dim, lbnd_in, 
                             ubnd_in, data_array + iv, ipv, ipw );
            }
         }

/* Free the dummy mapping. */
         fsmap = astAnnul( fsmap );

/* If we have not been using astRebinSeq to do the rebinning, do the 
   normalisation using hard-wired code. "iv" is the index into the full 3D
   output array, and "iv0" is the index into the 2D variance and weight
   arrays, each of which represents a single spatial plane from the
   output cube. */
      } else {

/* First normalise the 3D data array. */
         iv0 = 0;
         for( iv = 0; iv < nel; iv++,iv0++ ) {
            if( iv0 == nxy ) iv0 = 0;

            if( wgt_array[ iv0 ] > 0.0 && data_array[ iv ] != VAL__BADR ) {
               data_array[ iv ] /= wgt_array[ iv0 ];
            } else {
               data_array[ iv ] = VAL__BADR;
            }
         }

/* Now normalise the 2D variance array. First handle cases where the
   output variance is calculated on the basis of the spread of input
   values. */
         if( genvar == 1 ) {

/* Loop over every spectrum in the output cube. */
            for( iv0 = 0; iv0 < nxy; iv0++ ) {

/* Set output variance bad if less than 2 input spectra contributed to this 
   output spectrum. */
               if( wgt_array[ iv0 ] < 2.0 ) {
                  var_array[ iv0 ] = VAL__BADR;

/* Otherwise calculate output spectrum variance. */
               } else {

/* Find the sum of the squared data values in the current output
   spectrum, and the number of channels that have good data values. */
                  d2sum = 0.0;
                  ngoodchan = 0;
                  pdata = data_array + iv0;
                  for( ichan = 0; ichan < nchan; ichan++ ) {
                     if( *pdata != VAL__BADR ) {
                        d2sum += (*pdata)*(*pdata);
                        ngoodchan++;
                     }
                     pdata += nxy;
                  }

/* Form the normalised variance for the output spectrum. This is the mean
   of the variances for each channel. */              
                  if( ngoodchan > 0 ) {
                     var_array[ iv0 ] = ( var_array[ iv0 ]/work_array[ iv0 ] 
                                          - d2sum/ngoodchan )/( wgt_array[ iv0 ] - 1 );
                  } else {
                     var_array[ iv0 ] = VAL__BADR;
                  }

               }
            }

/* Now handle cases where the output variance is calculated on the basis of 
   the input Tsys values. They are just the recprocal of the sum of the 
   weights, since each weight is the recprocal of the associated input 
   variance. */
         } else if( genvar == 2 ) {
            for( iv0 = 0; iv0 < nxy; iv0++ ) {
               if( wgt_array[ iv0 ] > 0.0 ) {
                  var_array[ iv0 ] =  1.0/wgt_array[ iv0 ];
               } else {
                  var_array[ iv0 ] =  VAL__BADR;
               }
            }
         }
      }
   }

/* Free resources. */
   spectab = astFree( spectab );
   xin = astFree( xin );
   yin = astFree( yin );
   xout = astFree( xout );
   yout = astFree( yout );
   if( detwork ) detwork = astFree( detwork );
   if( varwork ) varwork = astFree( varwork );

/* End the AST context. This will annul all the AST objects created
   within the context. */
   astEnd;
}
