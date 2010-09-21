/*
*+
*  Name:
*     smf_fix_steps

*  Purpose:
*     Detect and correct any steps in the DC level in each bolometer.

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     C function

*  Invocation:
*     void smf_fix_steps( smfWorkForce *wf, smfData *data, double dcthresh,
*                         dim_t dcsmooth, dim_t dcfitbox, int dcmaxsteps,
*                         size_t *nrej, smfStepFix **steps, int *nsteps,
*                         int *bcount, int *status )

*  Arguments:
*     wf = smfWorkForce * (Given)
*        Pointer to a pool of worker threads (can be NULL)
*     data = smfData * (Given and Returned)
*        The data that will be repaired (in-place). Locations of steps
*        will have bit SMF__Q_JUMP set.
*     dcthresh = double (Given)
*        The minimum ratio of (residual difference between adjacent
*        median-smoothed samples) to (the local RMS in the residual
*        differences) for a real jump. Should be of the order ot 20-30.
*     dcsmooth = dim_t (Given)
*        The width in samples of the box to use when median smoothing the
*        original bolometer data. Should be not much larger than the
*        expected maximum width of a step (say 50).
*     dcfitbox = dim_t (Given)
*        Length of box (in samples) over which each linear fit is
*        performed. If zero, no steps will be corrected. Should be
*        smallish (say 40).
*     dcmaxsteps = int (Given)
*        The maximum number of steps that can be corrected in each minute
*        of good data (i.e. per 12000 samples) from a bolometer before the
*        entire bolometer is flagged as bad. A value of zero will cause a
*        bolometer to be rejected if any steps are found in the bolometer
*        data stream.
*     nrej = size_t * (Returned)
*        The number of bolometers rejected due to having too many steps.
*     steps = smfStepFix ** (Returned)
*        Address of a pointer to the first element of an array of
*        smfStepFix structures. If the pointer is NULL on entry, then a
*        new array is allocated and a pointer to the array is stored at the
*        supplied address on exit (the array should be freed using
*        astFree when no longer needed). If the supplied address is NULL,
*        then no array is allocated.
*
*        On exit, the number of elements in the array (if it exists) will
*        be equal to the value of "*nstep". Each element is a smfStepFix
*        structure that describes a single fixed step.
*     nstep = int * (Returned)
*        The number of fixed steps.
*     bcount = int * (Returned)
*        A pointer to an array with an element for each time slice. On
*        exit, each element is set to the number of bolometers found to have
*        a step at the corresponding time slice. A NULL pointer may be
*        supplied.
*     status = int* (Given and Returned)
*        Pointer to global status.

*  Description:
*     DC jumps are found and fixed in each bolometer independently of all
*     other bolometers.
*
*     The algorithm detects and measures DC jumps within the median
*     smoothed bolometer data. This is because median smoothing reduces
*     the noise whilst retaining the sharp edges at each DC jump (so long
*     as the smoothing is not too heavy), and also reduces the effect of
*     spikes, etc. After detecting and measuring all jump in the smoothed
*     bolometer data, the original unsmoothed bolometer data is corrected
*     to remove these jumps. An extra constant correction is applied in
*     order to retain the orignal mean data value in each bolometer.
*
*     The jump detection and measurement algorithm for a single bolometer
*     proceeds as follow:
*
*     The gradient at each sample is estimated by taking the difference
*     between the median smoothed data values on either side of the sample.
*     These differences contain both the local gradient in the
*     noise-free data, which is assumed to vary smoothly, and the
*     residual gradients caused by noise, spikes, DC jumps, etc. We need
*     to estimate the smoothly varying local gradient so that the residual
*     gradients - including DC jumps - can then be found. But we cannot
*     just smooth the differences to find the local gradient as jumps,
*     spikes etc will produce extended bumps in the local gradient. So we
*     first remove all differences which are more than three times the RMS
*     value of the differences (we also remove a small neighbourhood of
*     values around each such clipped value). We then smooth the remaining
*     differences, using a mean filter rather than a median for better
*     accuracy, to get the local gradient. Holes in this array are filled
*     in by linear interpolation.
*
*     The smooth local gradient is then subtracted off the original
*     differences to get the residual differences caused by noise, jumps,
*     spikes, etc. The local RMS value of these residual differences at
*     each sample is then found (this is done by smoothing the squared
*     differences using a median filter, and then taking the square root
*     of the smoothed squared differences). Blocks of samples that have
*     unusually large residual differences compared to the local RMS
*     value are then found (small gaps of low residual gradient are
*     allowed within these blocks). For each such block, a linear fit is
*     made to the median smoothed bolometer data just before the block
*     (leaving a small gap to avoid the areas of high gradient that seem
*     to preceed or follow many jumps). A similar linear fit is made just
*     after the end of the block. These two fits are used to produce
*     estimates of the expected data value at the centre of the block. If
*     this difference is large compared to the noise in the bolometer,
*     and also compared to the uncertainty in the jump height, then a
*     DC step is deemed to exist at the centre of the block, with height
*     equal to the difference between the central data value estimated by
*     the two fits. The uncertainty in the jump height is determined by
*     doing several other linear fits to the data is slightly shifted
*     boxes, and seeing how the jump height varies.

*  Authors:
*     David S Berry (JAC, Hawaii)
*     {enter_new_authors_here}

*  History:
*     11-MAR-2010 (DSB):
*        Original version.
*     25-MAR-2010 (DSB):
*        - Change dcminstepwidth from 20 to 0.8*dcwidth (instantaneous
*        steps should have a width of dcwidth).
*        - Change the way the median filtering is done to use one filter
*        rather than two. This should be faster.
*        - Reject blocks of steep samples if the median value at the
*        start and end of the block are insufficiently different.
*        - Extract median filtering code into another routine.
*     13-MAY-2010 (DSB):
*        - The RMS value in the gradient array could be badly affected
*        by very large steps. So do three 3*sigma rejection iterations
*        to make the rms more robust.
*        - Replace incorrect "break" with "continue". This could
*        cause the whole function to return early if a bolometer
*        with too few usable values was found.
*        - Correct counting of rejected bolometers (returned in *nrej).
*     18-MAY-2010 (DSB):
*        Ensure the first and last dcwidth samples in each bolometer
*        are continuous with the intermediate data.
*     21-MAY-2010 (DSB):
*        Added dclimcorr.
*     24-MAY-2010 (DSB):
*        - Do not alter the padding values at start and end of each bolometer
*        time series.
*        - Apodize the initial and final correction for each bolometer
*        time series, in the same way that smf_apodize does.
*     25-MAY-2010 (DSB):
*        - Increase dcmaxstepwidth from 1.8*dcwidth to
*        3.0*dcwidth (Remo has data which shows steps that include
*        two distinct sub-steps, separated by around 50 samples).
*        - Change dcminstepgap from 50 to 0.5*dcwidth to allow
*        such sub-steps (sometimes) to be processed as two separate steps.
*        - Re-organise the debugging facilities.
*        - If a step occurs too close to the start or end to be fixed,
*        flag all samples as a jump up tp the start or end.
*     28-MAY-2010 (DSB):
*        - Exclude data previously flagged as a jump when fitting data before
*        and after a candidate step.
*        - Fix incorrect indexing of quality array when steps are found close
*        to the start or end of the time series.
*        - Clip at 2 sigma (not 3) when finding the RMS gradient, and
*        then correct for the heavy clipping using the factor appropriate
*        for pure Gaussian noise. heavier clipping does better in the
*        presence of lots of steps.
*     11-JUN-2010 (DSB):
*        Report the number of fixed steps if in verbose mode.
*     25-JUN-2010 (DSB):
*        Apodisation is now done later in smf_execute_filter, so there
*        is no need to apodise in this function.
*     6-JUL-2010 (DSB):
*        - Rename old "nstep" argument as "nrej".
*        - Added arguments "steps" and "nstep".
*     27-AUG-2010 (DSB):
*        Complete re-write. The main difference is that the jumps are now
*        detected and measured in the median s,moothed bolometer data,
*        rather than the original bolometer data. But there are manu
*        other less significant changes too.
*     13-SEP-2010 (DSB):
*        Added argument "bcount".
*     21-SEP-2010 (DSB):
*        Ignore steps that occur close to bright sources. Such sources
*        cause flat sections in the median smoothed data that give the
*        appearance of a step in the residual differences.
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2010 Science & Technology Facilities Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 3 of
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

/* Starlink includes */
#include "ast.h"
#include "mers.h"
#include "sae_par.h"
#include "prm_par.h"

/* SMURF includes */
#include "libsmf/smf.h"
#include "libsmf/smf_typ.h"
#include "libsmf/smf_err.h"


/* Local data types: */
typedef struct smfFixStepsJobData {
   dim_t b1;
   dim_t b2;
   dim_t dcfitbox;
   dim_t dcsmooth;
   dim_t nbolo;
   dim_t ntslice;
   double *dat;
   double dccut;
   double dcthresh2;
   double dcthresh3;
   double dcthresh;
   int *bcount;
   int dcfill;
   int dcmaxsteps;
   int dcmaxwidth;
   int dcsmooth2;
   int nfixed;
   int nstep;
   size_t bstride;
   size_t nrej;
   size_t tstride;
   smfStepFix *steps;
   smf_qual_t *qua;
} smfFixStepsJobData;


/* Define macro DEBUG_STEPS here, if debugging info is needed. NOTE, only
   use debugging facilities in SINGLE THREADED mode.
#define DEBUG_STEPS 1
*/

typedef struct Step {
   dim_t start;
   dim_t end;
   double minjump;

#ifdef DEBUG_STEPS
   double error;
   double jump;
   int ok;
   int ibolo;
   int flat;
   double vlo;
   double vlo_mean;
   double vlo_sigma;
   double vhi;
   double vhi_mean;
   double vhi_sigma;
#endif

} Step;

#ifdef DEBUG_STEPS

#define RECORD_BOLO (ibolo==818)
#define RECORD_BOLO2 (1)

#define TOPCAT(fd, x) \
   if( x != VAL__BADD ) { \
      fprintf( fd, "%g ", x ); \
   } else { \
      fprintf( fd, "null " ); \
   }

typedef struct TimeData {
   double indata;
   int inquality;
   double outdata;
   int outquality;
   int ibolo;
   double median;
   double diff;
   double thresh;
   double sdiff;
   double rdiff;
   double mdiff;
   double mdiff2;
   double diff2;
   double rms;
   int instep;
   int step_width;
   double total;
   double snr;
} TimeData;


#endif



/* Prototypes for private functions defined in this file. */

static int smf1_correct_steps( dim_t ntslice, double *dat, smf_qual_t *qua,
                               size_t tstride, double *median, double *snr,
                               dim_t dcfitbox, double dcthresh2,
                               int nbstep, Step *bsteps, int ibolo,
                               smfStepFix **steps, int *nsteps,
                               double *grad, double *off, int *bcount,
                               int *status );

static void smf1_fix_steps_job( void *job_data, int *status );





/* Main entry point. */

void smf_fix_steps( smfWorkForce *wf, smfData *data, double dcthresh,
                    dim_t dcsmooth, dim_t dcfitbox, int dcmaxsteps,
                    size_t *nrej, smfStepFix **steps, int *nstep,
                    int *bcount, int *status ) {

/* Local Variables */
   dim_t itime;
   dim_t nbolo;
   dim_t ntslice;
   double *dat = NULL;
   int bstep;
   int istep;
   int iworker;
   int nfixed;
   int nworker;
   size_t bstride;
   size_t tstride;
   smfFixStepsJobData *pdata = NULL;
   smfFixStepsJobData *job_data = NULL;
   smf_qual_t *qua = NULL;

/* The minimum number of samples between steps. Large differences that
   are separated by less than "dcfill" samples are considered to be part of
   the same jump. */
   int dcfill = 40;

/* The maximum width of a step. Candidate steps that are wider than this
   number of samples are left uncorrected. */
   int dcmaxwidth = 60;

/* The size of the median filter to use when estimating the local RMS at
   each point. */
   int dcsmooth2 = 200;

/* The sigma threshold for points to be included in the estimation of the
   local gradient at each point. */
   double dccut = 4.0;

/* The sigma threshold for acceptable jumps - the ratio of jump height to
   the uncertainty in jump height caused by moving the fitting area. */
   double dcthresh2 = 1.5;

/* The smallest jump to be corrected, as a factor of the local RMS
   noise in the bolometer data. */
   double dcthresh3 = 4.0;

/* Initialise... */
   if( nstep ) *nstep = 0;
   if( nrej ) *nrej = 0;
   nfixed = 0;

/* Check the inherited status. */
   if( *status != SAI__OK ) return;

/* Check we have double precision data. */
   if( !smf_dtype_check_fatal( data, NULL, SMF__DOUBLE, status ) ) return;

/* Used to dump the input data (e.g. for use in a regression test). Must
   be time ordered, otherwise errors occurr when smf_open_file opens the
   file. */
#ifdef DUMP_INPUT
   int isT = data->isTordered;
   msgOut( "", "Dumping smf_fix_steps input data to NDF 'fix_steps_input.sdf'.",
           status );
   smf_dataOrder( data, 1, status );
   smf_write_smfData ( data, NULL,
                     "fix_steps_input", NULL, 0, 0, status );
   smf_dataOrder( data, isT, status );
#endif

/* Get pointers to data and quality arrays. */
   dat = data->pntr[ 0 ];
   qua = smf_select_qualpntr( data, NULL, status );

/* Report an error if either are missing. */
   if( !qua ) {
      *status = SAI__ERROR;
      errRep( "", "smf_fix_steps: No valid QUALITY array was provided", status );

   } else if( !dat ) {
      *status = SAI__ERROR;
      errRep( "", "smf_fix_steps: smfData does not contain a DATA component",
              status );
   }

/* Get the data dimensions and strides. */
   smf_get_dims( data,  NULL, NULL, &nbolo, &ntslice, NULL, &bstride,
                 &tstride, status );

/* Report an error if the data stream is too short for the box size. */
   if( dcfitbox*2 > ntslice && *status == SAI__OK ) {
      *status = SAI__ERROR;
      msgSeti( "NTSLICE", ntslice );
      msgSeti( "dcfitbox", dcfitbox );
      errRep( " ", "smf_fix_steps: Can't find jumps: ntslice=^NTSLICE, "
              "must be > dcfitbox (=^dcfitbox)*2", status );
   }

/* Check for valid threshold */
   if( dcthresh <= 0  && *status == SAI__OK ) {
      *status = SAI__ERROR;
      msgSetd( "DCTHRESH", dcthresh );
      errRep( " ", "smf_fix_steps: Can't find jumps: dcthresh "
              "(^dcthresh) must be > 0", status );
   }

/* Create structures used to pass information to the worker threads. */
   nworker = wf ? wf->nworker : 1;

#ifdef DEBUG_STEPS
   nworker = 1;
#endif

   job_data = astMalloc( nworker*sizeof( *job_data ) );

/* Find and repair DC steps. */
   if( dcfitbox && (*status == SAI__OK) ) {

/* Determine which bolometers are to be processed by which threads. */
      bstep = nbolo/nworker;
      if( bstep < 1 ) bstep = 1;

      for( iworker = 0; iworker < nworker; iworker++ ) {
         pdata = job_data + iworker;
         pdata->b1 = iworker*bstep;
         pdata->b2 = pdata->b1 + bstep - 1;
      }

/* Ensure that the last thread picks up any left-over bolometers */
      pdata->b2 = nbolo - 1;

/* Store all the other info needed by the worker threads, and submit the
   jobs to fix the steps in each bolo, and then wait for them to complete. */
      for( iworker = 0; iworker < nworker; iworker++ ) {
         pdata = job_data + iworker;

         pdata->bstride = bstride;
         pdata->dat = dat;
         pdata->dccut = dccut;
         pdata->dcfill = dcfill;
         pdata->dcfitbox = dcfitbox;
         pdata->dcmaxsteps = dcmaxsteps;
         pdata->dcmaxwidth = dcmaxwidth;
         pdata->dcsmooth = dcsmooth;
         pdata->dcthresh = dcthresh;
         pdata->dcsmooth2 = dcsmooth2;
         pdata->dcthresh2 = dcthresh2;
         pdata->dcthresh3 = dcthresh3;
         pdata->nbolo = nbolo;
         pdata->ntslice = ntslice;
         pdata->qua = qua;
         pdata->tstride = tstride;
         pdata->nstep = ( steps && nstep ) ? 1 : 0;

/* Allocate work array to hold, for each time slice, the total number of
   bolometers found to be in a jump at that time slice. Initialise it to
   hold zero at every element. */
         pdata->bcount = bcount ?
                         astCalloc( ntslice, sizeof( *(pdata->bcount) ), 1 ) :
                         NULL;

/* Pass the job to the workforce for execution. */
         smf_add_job( wf, SMF__REPORT_JOB, pdata, smf1_fix_steps_job, NULL,
                      status );
      }

/* Wait for the workforce to complete all jobs. */
      smf_wait( wf, status );

/* Accumuate the returned values from each thread. */
      for( iworker = 0; iworker < nworker; iworker++ ) {
         pdata = job_data + iworker;

         nfixed += pdata->nfixed;
         if( nrej ) *nrej += pdata->nrej;

         if( steps && nstep ) {
            istep = *nstep;
            *nstep += pdata->nstep;
            *steps = astGrow( *steps, *nstep, sizeof( **steps ) );

            if( *status == SAI__OK ) {
               memcpy( *steps + istep, pdata->steps,
                       pdata->nstep*sizeof( **steps ) );
            }
         }

         pdata->steps = astFree( pdata->steps );

         if( bcount ) {
            if( iworker == 0 ) {
               for( itime = 0; itime < ntslice; itime++ ) {
                  bcount[ itime ] = pdata->bcount[ itime ];
               }
            } else if( pdata->bcount ) {
               for( itime = 0; itime < ntslice; itime++ ) {
                  bcount[ itime ] += pdata->bcount[ itime ];
               }
            }
            pdata->bcount = astFree( pdata->bcount );
         }

      }
   }

/* Report the number of fixed steps */
   msgOutiff( MSG__VERB, " ", "smf_fix_steps: fixed %d steps.",
              status, nfixed );

/* Report the number of rejected bolometers. */
   if( *nrej > 0 ) {
      msgOutiff( MSG__VERB, " ", "smf_fix_steps: flagged %zu bad bolos.",
                 status, *nrej );
   }

/* Return the number of fixed steps. */
   if( nstep ) *nstep = nfixed;

/* Free resources. */
   job_data = astFree( job_data );
}


static void smf1_fix_steps_job( void *job_data, int *status ) {
/*
*  Name:
*     smf1_fix_steps_job

*  Purpose:
*     Find the gain and offset for each bolo block.

*  Invocation:
*     void smf1_fix_steps_job( void *job_data, int *status )

*  Arguments:
*     job_data = void * (Given)
*        Pointer to the data needed by the job. Should be a pointer to a
*        smfFixStepsJobData structure.
*     status = int * (Given and Returned)
*        Pointer to global status.

*  Description:
*     This routine finds and fixes steps in a block of bolometers. It
*     runs within a thread instigated by smf_fix_steps.

*/

/* Local Variables: */
   Step *bsteps = NULL;
   dim_t b1;
   dim_t b2;
   dim_t dcfitbox;
   dim_t dcsmooth;
   dim_t ibolo;
   dim_t itime;
   dim_t nbolo;
   dim_t ntslice;
   double *dat = NULL;
   double *mw1;
   double *pd;
   double *pw1_hi;
   double *pw1_lo;
   double *pw2;
   double *pw3;
   double *pw4;
   double *w1;
   double *w2;
   double *w3;
   double *w4;
   double *w5;
   double bolonoise;
   double dccut;
   double dcthresh2;
   double dcthresh3;
   double dcthresh;
   double delta;
   double diff2;
   double diff;
   double lval;
   double max_snr_jump;
   double rdiff;
   double rms;
   double sdiff;
   double snr_jump;
   double sum2;
   double thresh;
   double total;
   double vlo;
   int *mw3;
   int *bcount;
   int allequal;
   int dcfill;
   int dcmaxsteps;
   int dcmaxwidth;
   int dcsmooth2;
   int gap_start;
   int ibstep;
   int iter;
   int jhi;
   int jlo;
   int jtime;
   int lbad;
   int mbstep;
   int msize;
   int nbstep;
   int nfixed;
   int nrej;
   int nstep;
   int nsum;
   int pad;
   int step_end;
   int step_limit;
   int step_start;
   int step_width;
   size_t *mw2;
   size_t base;
   size_t bstride;
   size_t tstride;
   smfFixStepsJobData *pdata;
   smfStepFix *steps;
   smf_qual_t *pq;
   smf_qual_t *qua = NULL;
   struct timeval tv1;
   struct timeval tv2;

   int dcgappad = 50;

/* Check inherited status */
   if( *status != SAI__OK ) return;

/* Get a pointer to the job data, and then extract its contents into a
   set of local variables. */
   pdata = (smfFixStepsJobData *) job_data;

   b1 = pdata->b1;
   b2 = pdata->b2;
   bstride = pdata->bstride;
   bcount = pdata->bcount;
   dat = pdata->dat;
   dccut = pdata->dccut;
   dcfill = pdata->dcfill;
   dcfitbox = pdata->dcfitbox;
   dcmaxsteps = pdata->dcmaxsteps;
   dcmaxwidth = pdata->dcmaxwidth;
   dcsmooth = pdata->dcsmooth;
   dcsmooth2 = pdata->dcsmooth2;
   dcthresh = pdata->dcthresh;
   dcthresh2 = pdata->dcthresh2;
   dcthresh3 = pdata->dcthresh3;
   nbolo = pdata->nbolo;
   ntslice = pdata->ntslice;
   qua = pdata->qua;
   tstride = pdata->tstride;

/* Initialise the returned values. */
   nrej = 0;
   bsteps = NULL;
   steps = NULL;
   nstep = 0;
   nfixed = 0;

/* Check we have something to do. */
   if( b1 < nbolo ) {

/* Debugging message indicating thread started work */
      msgOutiff( MSG__DEBUG, "", "smfFixSteps: thread starting on bolos %zu -- %zu",
                 status, b1, b2 );
      smf_timerinit( &tv1, &tv2, status);

#ifdef DEBUG_STEPS
   FILE *fd2 = fopen( "timedata.asc", "w" );
   fprintf( fd2, "# itime indata inquality outdata outquality ibolo median "
            "diff thresh sdiff rdiff mdiff mdiff2 diff2 rms instep step_width total snr\n");

   FILE *fd3 = fopen( "stepdata.asc", "w" );
   fprintf( fd3, "# ibstep start end minjump error jump ok ibolo "
            "jump flat vlo vlo_mean vlo_sigma vhi vhi_mean vhi_sigma\n" );

   TimeData *timedata = astMalloc( ntslice*sizeof( *timedata ) );
#endif

/* Allocate work arrays. */
      w1 = astMalloc( sizeof( *w1 )*ntslice );
      w2 = astMalloc( sizeof( *w2 )*ntslice );
      w3 = astMalloc( sizeof( *w3 )*ntslice );
      w4 = astMalloc( sizeof( *w4 )*ntslice );
      w5 = astMalloc( sizeof( *w5 )*ntslice );

      msize = dcsmooth;
      if( dcsmooth2 > msize ) msize = dcsmooth2;
      mw1 = astMalloc( sizeof( *mw1 )*msize );
      mw2 = astMalloc( sizeof( *mw2 )*msize );
      mw3 = astMalloc( sizeof( *mw3 )*msize );

/* Ensure dcfitbox is odd. */
      dcfitbox = 2*( dcfitbox/2 ) + 1;

/* Loop round all bolometers to be processed by this thread. "base" holds the
   offset to the start of the data for the bolometer.  */
      for( ibolo = b1; ibolo <= b2 && *status==SAI__OK; ibolo++ ) {
         base = ibolo*bstride;
         pq = qua + base;
         if( !(*pq & SMF__Q_BADB) ) {

#ifdef DEBUG_STEPS

   if( RECORD_BOLO ) {
      dim_t kk;
      pd = dat + base;
      pq = qua + base;
      for( kk = 0; kk < ntslice; kk++ ) {
         timedata[ kk ].indata = *pd;
         timedata[ kk ].inquality = (int) *pq;
         timedata[ kk ].outdata = VAL__BADD;
         timedata[ kk ].outquality = 0;
         timedata[ kk ].ibolo = ibolo;
         timedata[ kk ].median = VAL__BADD;
         timedata[ kk ].diff = VAL__BADD;
         timedata[ kk ].thresh = VAL__BADD;
         timedata[ kk ].sdiff = VAL__BADD;
         timedata[ kk ].rdiff = VAL__BADD;
         timedata[ kk ].mdiff = VAL__BADD;
         timedata[ kk ].mdiff2 = VAL__BADD;
         timedata[ kk ].diff2 = VAL__BADD;
         timedata[ kk ].rms = VAL__BADD;
         timedata[ kk ].instep = 0;
         timedata[ kk ].step_width = 0;
         timedata[ kk ].total = VAL__BADD;
         timedata[ kk ].snr = VAL__BADD;

         pd += tstride;
         pq += tstride;
      };
      pq = qua + base;
   }

#endif

/* Median smooth the input data, putting the results in w1. */
            smf_median_smooth( dcsmooth, SMF__FILT_MEDIAN, -1.0, ntslice,
                               dat + base, qua + base, tstride, SMF__Q_GOOD,
                               w1, mw1, mw2, mw3, status );

/* Into each sample of w2 put the difference between the two adjacent
   median smoothed data values. Store a copy of these differences in w3.
   Also form the sums needed to calculate the RMS of the differences. */
            pw1_lo = w1;
            pw1_hi = w1 + 2;
            pw2 = w2 + 1;
            pw3 = w3 + 1;
            allequal = 1;
            nsum = 0;
            sum2 = 0.0;

            w2[ 0 ] = w3[ 0 ] = VAL__BADD;

            for( itime = 1; itime < ntslice - 1; itime++,pw1_lo++,pw1_hi++ ) {

               if( *pw1_lo != VAL__BADD && *pw1_hi != VAL__BADD ) {
                  diff = *pw1_hi - *pw1_lo;
                  sum2 += diff*diff;
                  nsum++;
                  if( diff != 0.0 ) allequal = 0;
               } else {
                  diff = VAL__BADD;
               }

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      timedata[ itime ].median = w1[itime];
      timedata[ itime ].diff = diff;
   }
#endif

               *(pw2++) = *(pw3++) = diff;
            }

            w2[ itime ] = w3[ itime ] = VAL__BADD;

/* If the time stream contains too few values, or all values are equal,
   flag the entire bolometer as bad, and pass on to the next bolometer. */
            if( nsum <= SMF__MINSTATSAMP || allequal ) {
               msgOutiff( MSG__DEBUG, "", "smf_fix_steps: flagging "
                          "entire bad bolo %" DIM_T_FMT ", due to "
                          "insufficient samples", status, ibolo );
               pq = qua + base;
               for( itime = 0; itime < ntslice; itime++) {
                 *pq |= SMF__Q_BADB;
                  pq += tstride;
               }
               nrej++;
               continue;
            }

/* Do two sigma-clipping iterations to prevent the RMS being heavily
   affected by abberant values. */
            for( iter = 0; iter < 2 && nsum > 0; iter++ ) {

/* Get the RMS of the difference values. */
               rms = sqrt( sum2/nsum );

/* Set the w3 differences bad if they are bigger than "dccut" times the
   rms, and update the sums to exclude these samples. */
               thresh = dccut*rms;
               pw3 = w3;
               for( itime = 0; itime < ntslice; itime++,pw3++ ) {
                  if( *pw3 != VAL__BADD && fabs( *pw3 ) > thresh ) {
                     diff = *pw3;
                     *pw3 = VAL__BADD;
                     sum2 -= diff*diff;
                     nsum--;
                  }
               }
            }



#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      pw3 = w3;
      for( itime = 0; itime < ntslice; itime++ ) {
         timedata[ itime ].mdiff = *(pw3++);
      }
   }
#endif



/* Expand sections of bad samples in w3 to avoid using samples on the
   edges of steps when estimating the local gradient. Each section is
   doubled in width, whilst retaining the original centre. First take a
   copy of w3 (in w4), and then modify the values in w3. */
            w4 = astStore( w4, w3, ntslice*sizeof( *w3 ) );
            pw3 = w3;
            pw4 = w4;
            lbad = 0;
            jlo = -1;
            for( itime = 0; itime < ntslice; itime++,pw3++,pw4++ ) {
               if( lbad ) {
                  if( *pw4 != VAL__BADD ) {
                     jhi = itime - 1;
                     lbad = 0;

                     pad = ( jhi - jlo )/2;
                     if( pad < 4 ) pad = 4;

                     jhi = jhi + pad;
                     if( jhi >= (int) ntslice ) jhi = ntslice - 1;

                     jlo = jlo - pad;
                     if( jlo < 0 ) jlo = 0;

                     for( jtime = jlo; jtime <= jhi; jtime++ ) w3[ jtime ] = VAL__BADD;
                  }
               } else {
                  if( *pw4 == VAL__BADD ) {
                     jlo = itime;
                     lbad = 1;
                  }
               }
            }


#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      pw3 = w3;
      for( itime = 0; itime < ntslice; itime++ ) {
         timedata[ itime ].mdiff2 = *(pw3++);
      }
   }
#endif

/* Find the RMS of the difference between adjacent samples in the
   bolometer data, excluding aberrant points. We need to be more cautious
   when dealing with the raw bolometer data rather than the
   median-smoothed bolometer data, since it will contain more abberant
   points. So first widen the bad pixel ranges.  */
            w4 = astStore( w4, w3, ntslice*sizeof( *w3 ) );
            pw3 = w3;
            pw4 = w4;
            lbad = 0;
            for( itime = 0; itime < ntslice; itime++,pw3++,pw4++ ) {
               if( lbad ) {
                  if( *pw3 != VAL__BADD ) {
                     jhi = ntslice - itime;
                     if( jhi > dcgappad ) jhi = dcgappad;
                     for( jtime = 0; jtime < jhi; jtime++ ) pw4[ jtime ] = VAL__BADD;
                     lbad = 0;
                  }
               } else {
                  if( *pw3 == VAL__BADD ) {
                     jlo = -itime;
                     if( jlo < -dcgappad ) jlo = -dcgappad;
                     for( jtime = jlo; jtime < 0; jtime++ ) pw4[ jtime ] = VAL__BADD;
                     lbad = 1;
                  }
               }
            }

/* Now find the RMS noise in the remaining bolometer data. */
            nsum = 0;
            sum2 = 0.0;
            pw4 = w4;
            pd = dat + base;
            lval = VAL__BADD;
            for( itime = 0; itime < ntslice; itime++,pw4++ ) {
               if( *pw4 != VAL__BADD ){
                  if( *pd != VAL__BADD && lval != VAL__BADD ) {
                     diff = *pd - lval;
                     sum2 += diff*diff;
                     nsum++;
                  }
                  lval = *pd;
               } else {
                  lval = VAL__BADD;
               }
               pd += tstride;
            }

            if( nsum <= SMF__MINSTATSAMP ) {
               msgOutiff( MSG__DEBUG, "", "smf_fix_steps: flagging "
                          "entire bad bolo %" DIM_T_FMT ", due to "
                          "insufficient samples", status, ibolo );
               pq = qua + base;
               for( itime = 0; itime < ntslice; itime++) {
                 *pq |= SMF__Q_BADB;
                  pq += tstride;
               }
               nrej++;
               continue;
            }

            bolonoise = 0.707*sqrt( sum2/nsum );

/* Smooth the clipped differences with a mean tophat filter to get an
   estimate of the underlying local gradient. */
            smf_tophat1D( w3, ntslice, dcsmooth, NULL, 0, 0.2, status );

/* Fill any holes in the smoothed differences using linear interpolation. */
            gap_start = -1;
            vlo = VAL__BADD;

            pw3 = w3;
            for( itime = 0; itime < ntslice; itime++,pw3++ ) {
               if( *pw3 == VAL__BADD ) {
                  if( gap_start == -1 ) gap_start = itime;

               } else {
                  if( gap_start != -1 && vlo != VAL__BADD ) {

                     delta = ( *pw3 - vlo )/( itime - gap_start + 1 );
                     for( jtime = gap_start; jtime < (int) itime; jtime++ ) {
                        vlo += delta;
                        w3[ jtime ] = vlo;
                     }

                     gap_start = -1;
                  }

                  vlo = *pw3;
               }
            }

/* Subtract the smoothed differences from the original differences, and
   store the squared residual differences in w3. */
            pw2 = w2;
            pw3 = w3;
            for( itime = 0; itime < ntslice; itime++,pw2++,pw3++ ) {
               if( *pw2 != VAL__BADD && *pw3 != VAL__BADD ) {
                  sdiff = *pw3;
                  rdiff = *pw2 - sdiff;
                  *pw2 = rdiff;
                  *pw3 = rdiff*rdiff;

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      timedata[ itime ].sdiff = sdiff;
      timedata[ itime ].rdiff = rdiff;
      timedata[ itime ].diff2 = *pw3;
   }
#endif

               } else {
                  *pw2 = *pw3 = VAL__BADD;
               }
            }

/* Smooth the squared residual differences with a median filter. */
            smf_median_smooth( dcsmooth2, SMF__FILT_MEDIAN, 0.0, ntslice,
                               w3, NULL, 1, 0, w4, mw1, mw2, mw3, status );

/* Find the start and end of each block of contiguous high differences.
   Each is a candidate step. */
            nbstep = 0;
            step_start = -1;
            step_end = 0;
            step_limit = 0;
            total = 0.0;
            max_snr_jump = 0.0;

            pw2 = w2;
            pw3 = w3;
            pw4 = w4;
            for( itime = 0; itime < ntslice; itime++,pw2++,pw3++,pw4++ ) {

               diff = *pw2;
               diff2 = *pw4;
               if( diff != VAL__BADD && diff2 != VAL__BADD &&
                   diff2 > 0.0 ) {

/* Get the RMS of the residual differences around the current sample, and
   store the signal to noise ratio for the step in w3. */
                  rms = sqrt( *pw4 );
                  *pw3 = diff/rms;

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      timedata[ itime ].snr = diff/rms;
   }
#endif

/* If the residual difference at the current sample is large compared to
   the RMS, it is considered to be a jump. */
                  if( fabs( diff ) > dcthresh*rms ) {

/* A jump may extend over more than 1 sample, so we group localised clumps
   of high differences together. If we are not currently within such a
   group, record the current time index as the start of a new group. */
                     if( step_start == -1 ) {
                        step_start = itime;
                        total = 0.0;
                        max_snr_jump = 0.0;
                     }

/* The group extends at least as far as the current sample. */
                     step_end = itime;

/* Do not consider the group to be finished until we have found "dcfill"
   small differences following the last large difference. */
                     step_limit = itime + dcfill;

/* Find the maximum SNR jump. */
                     snr_jump = diff/rms;
                     if( fabs( snr_jump ) > max_snr_jump ) {
                        max_snr_jump = fabs( snr_jump );
                     }

/* Increment the total jump in value over the group. */
                     total += snr_jump;

/* If the current residual difference is small, and we have had "dcfill"
   small residuals since the end of the last group, we now know where the
   last group ended so we can go on to process the group. */
                  } else if( (int) itime == step_limit ) {

/* Check the group is not too wide, and that the total jump in value is not
   too small. */
                     step_width = step_end - step_start + 1;

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      for( jtime = step_start; jtime <= step_end; jtime++ ) {
         timedata[ jtime ].step_width = step_width;
         timedata[ jtime ].total = total;
      }
   }
#endif

                     if( step_width <= dcmaxwidth && fabs( total ) > dcthresh
                         && fabs( total ) > 0.5*max_snr_jump ) {

/* Create a new structure to describe the group, and add it to the array
   of such groups. */
                        ibstep = nbstep++;
                        bsteps = astGrow( bsteps, nbstep, sizeof( *bsteps ) );
                        if( *status == SAI__OK ) {
                           bsteps[ ibstep ].start = step_start;
                           bsteps[ ibstep ].end = step_end;
                           bsteps[ ibstep ].minjump = dcthresh3*bolonoise;


#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      for( jtime = step_start; jtime <= step_end; jtime++ ) {
         timedata[ jtime ].instep = 1;
      }
   }
#endif


                        }
                     }

/* We can now start looking for a new step. */
                     step_start = -1;
                  }

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      timedata[ itime ].rms = rms;
   }
#endif

               } else {
                  *pw3 = VAL__BADD;
               }
            }

/* We now have the starting and ending times for all the candidate jumps
   in the current bolometer. Attempt to measure each candidate step, and
   correct the bolometer data for each succesfully measured step. */
            mbstep = smf1_correct_steps( ntslice, dat + base, qua + base,
                                         tstride, w1, w3, dcfitbox, dcthresh2,
                                         nbstep, bsteps, ibolo,
                                         (pdata->nstep)?&steps:NULL,
                                         (pdata->nstep)?&nstep:NULL,
                                         w4, w5, bcount, status );

#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      for( ibstep = 0; ibstep < nbstep; ibstep++ ) {
         fprintf( fd3, "%d ", ibstep);
         fprintf( fd3, "%d ", bsteps[ibstep].start );
         fprintf( fd3, "%d ", bsteps[ibstep].end );
         TOPCAT( fd3, bsteps[ibstep].minjump );
         TOPCAT( fd3, bsteps[ibstep].error );
         TOPCAT( fd3, bsteps[ibstep].jump );
         fprintf( fd3, "%d ", bsteps[ibstep].ok );
         fprintf( fd3, "%d ", bsteps[ibstep].ibolo );
         TOPCAT( fd3, bsteps[ibstep].jump );
         fprintf( fd3, "%d ", bsteps[ibstep].flat );
         TOPCAT( fd3, bsteps[ibstep].vlo );
         TOPCAT( fd3, bsteps[ibstep].vlo_mean );
         TOPCAT( fd3, bsteps[ibstep].vlo_sigma );
         TOPCAT( fd3, bsteps[ibstep].vhi );
         TOPCAT( fd3, bsteps[ibstep].vhi_mean );
         TOPCAT( fd3, bsteps[ibstep].vhi_sigma );
         fprintf( fd3, "\n" );
      }
   }
#endif


/* Reject the whole bolometer if too many steps were fixed. */
            if( dcmaxsteps > 0 && mbstep > dcmaxsteps*nsum/12000.0 ) {
               pq = qua + base;
               for( itime = 0; itime < ntslice; itime++ ) {
                  *pq |= SMF__Q_BADB;
                  pq += tstride;
               }

               msgOutiff( MSG__DEBUG, " ", "smf_fix_steps: "
                          "flagging bad bolo %" DIM_T_FMT,
                          status, ibolo );

               nrej++;
            }

/* Increment the total number of steps that have been fixed. */
            nfixed += mbstep;

#ifdef DEBUG_STEPS
   if( RECORD_BOLO ) {
      pd = dat + base;
      pq = qua + base;

      for( itime = 0; itime < ntslice; itime++ ) {
         timedata[ itime ].outdata = *pd;
         timedata[ itime ].outquality = (int) *pq;
         pd += tstride;
         pq += tstride;

         fprintf( fd2, "%d ", itime);
         TOPCAT( fd2, timedata[itime].indata );
         fprintf( fd2, "%d ", timedata[itime].inquality);
         TOPCAT( fd2, timedata[itime].outdata );
         fprintf( fd2, "%d ", timedata[itime].outquality);
         fprintf( fd2, "%d ", timedata[itime].ibolo);
         TOPCAT( fd2, timedata[ itime ].median );
         TOPCAT( fd2, timedata[ itime ].diff );
         TOPCAT( fd2, timedata[ itime ].thresh );
         TOPCAT( fd2, timedata[ itime ].sdiff );
         TOPCAT( fd2, timedata[ itime ].rdiff );
         TOPCAT( fd2, timedata[ itime ].mdiff );
         TOPCAT( fd2, timedata[ itime ].mdiff2 );
         TOPCAT( fd2, timedata[ itime ].diff2 );
         TOPCAT( fd2, timedata[ itime ].rms );
         fprintf( fd2, "%d ", timedata[itime].instep );
         fprintf( fd2, "%d ", timedata[itime].step_width );
         TOPCAT( fd2, timedata[ itime ].total );
         TOPCAT( fd2, timedata[ itime ].snr );
         fprintf( fd2, "\n" );
      }
   }
#endif


         }
      }

/* Free workspace */
      w1 = astFree( w1 );
      w2 = astFree( w2 );
      w3 = astFree( w3 );
      w4 = astFree( w4 );
      w5 = astFree( w5 );
      bsteps = astFree( bsteps );
      mw1 = astFree( mw1 );
      mw2 = astFree( mw2 );
      mw3 = astFree( mw3 );

/* Report the time taken in this thread. */
      msgOutiff( SMF__TIMER_MSG, "",
                 "smfFixSteps: thread finishing bolos %zu -- %zu (%.3f sec)",
                 status, b1, b2, smf_timerupdate( &tv1, &tv2, status ) );


#ifdef DEBUG_STEPS
   fclose( fd2 );
   fclose( fd3 );
#endif


   }

/* Return values. */
   pdata->nrej = nrej;
   pdata->steps = steps;
   pdata->nstep = nstep;
   pdata->nfixed = nfixed;

}





















static int smf1_correct_steps( dim_t ntslice, double *dat, smf_qual_t *qua,
                               size_t tstride, double *median, double *snr,
                               dim_t dcfitbox, double dcthresh2,
                               int nbstep, Step *bsteps, int ibolo,
                               smfStepFix **steps, int *nsteps,
                               double *grad, double *off, int *bcount,
                               int *status ){
/*
*  Name:
*     smf1_correct_steps

*  Purpose:
*     Measure each candidate step for a single bolometer, and correct the
*     bolometer data.

*  Invocation:
*     int smf1_correct_steps( dim_t ntslice, double *dat, smf_qual_t *qua,
*                             size_t tstride, double *median, double *rms,
*                             dim_t dcfitbox, double dcthresh2,
*                             int nbstep, Step *bsteps, int ibolo,
*                             smfStepFix **steps, int *nsteps, double *grad,
*                             double *off, int *bcount, int *status )

*  Arguments:
*     ntslice = dim_t (Given)
*        The number of bolometer samples.
*     dat = double * (Given and Returned)
*        The bolometer data. On exit, it is corrected to remove each
*        succesfully measured jump. A constant offset is added to all
*        samples in order to retain the original mean value.
*     qua = smf_qual_t * (Given and Returned)
*        The bolometer quality. On exit, each step within a succesfully
*        measured jump is flagged with SMF__Q_JUMP.
*     tstride = size_t (Given)
*        The the number of elements in "dat" between adjacent bolometer
*        samples.
*     median = double * (Given)
*        The median filtered bolometer data. Used to determine the height
*        of each jump.
*     snr = double * (Given)
*        The ratio of the residual difference to the local RMS at every
*        sample.
*     dcfitbox = dim_t (Given)
*        Length of box (in samples) over which each linear fit is
*        performed. Two fits are performed - one just below the step and
*        one just above. These are used to determine the height of the jump.
*     dcthresh2 = double (Given)
*        N-sigma threshold for acceptable jumps. A jump must be more than
*        dcthresh2 times the larger of the RMS deviations in the two
*        linear fits.
*     nbstep = int (Given)
*        The number of candidate steps to be measured.
*     bsteps = Step * (given)
*        An array of structures describing each candidate step.
*     ibolo = int (Given)
*        The index of the bolometer being fixed.
*     steps = smfStepFix ** (Given and Returned)
*        An address at which to store a pointer to an array holding a
*        description of each sucessfully fixed step. The supplied array
*        (if any) is extended on exit to hold descriptions of the steps
*        fixed by the current invocation of this function.
*     nsteps = int * (Given and Returned)
*        On entry, the number of elements in the supplied "steps" array.
*        On exit, the number of elements in the returned "steps" array.
*     grad = double * (Given and Returned)
*        Pointer to a work array with at least dcfitbox elements.
*     off = double * (Given and Returned)
*        Pointer to a work array with at least dcfitbox elements.
*     bcount = int * (Given and Returned)
*        Pointer to a work array with one element for each time slice.
*        Each element holds the number of bolometers found to be within a
*        step at the corresponding time slice. May be NULL.
*     status = int* (Given and Returned)
*        Pointer to global status.

*  Description:
*     Each candidate jump described by the "steps" array is measured
*     within the supplied median filtered bolometer data, and if the jump
*     is significant compared to the variation in the nearby data, then
*     the supplied bolometer data is corrected to remove the jump. The
*     supplied quality array is also flagged with SMF__Q_JUMP for each
*     sample within the step.
*
*     The height of each jump is found by fitting two straight lines to
*     the median smoothed data; one just before the step and one just
*     after the step. Each of these two fits are used to estimate the
*     expected data value at the centre of the step, and the jump height
*     is then equal to the difference between these two estimates.
*
*     This jump height is compared to the RMS deviation of the data values
*     within each of the two fits. To be accepted, the jump must be more than
*     "dcthresh2" times the larger of the two RMS deviations.
*
*     Finally, a constant offset is added to the corrected bolometer data
*     in order to retain the original mean data value.

*/


/* Local Variables: */
   Step *step;
   dim_t itime;
   dim_t step_centre;
   dim_t step_end;
   int lstep_end;
   dim_t step_start;
   double *pd;
   double *pg;
   double *po;
   double *psnr;
   double corr;
   double err0;
   double error;
   double jump;
   double mean;
   double scorr;
   double snrv;
   double sum1;
   double sum2;
   double v;
   double vhi;
   double vhi_mean;
   double vhi_var;
   double vlo;
   double vlo_mean;
   double vlo_var;
   int count;
   int ibstep;
   int jhi;
   int jlo;
   int jtime;
   int ncorr;
   int nsum;
   int result;
   smf_qual_t *pq2;
   smf_qual_t *pq;
   double *pw;
   double flat_val;
   int flat_width;
   double tol;
   int bad;

   int dcnlow = 5;
   double dcsiglow = 8.0;
   int dcflatwidth = 10;

/* Initialise result prior to checking status. */
   result = 0;

/* Check inherited status */
   if( *status != SAI__OK ) return result;

/* Initialise other things. */
   pd = dat;
   pq = qua;
   itime = 0;
   corr = 0.0;
   scorr = 0.0;
   ncorr = 0;
   lstep_end = 0;

/* Loop round each candidate step. */
   step = bsteps;
   for( ibstep = 0; ibstep  < nbstep; ibstep++,step++ ) {

/* Note the step centre for later use. */
      step_centre = ( step->start + step->end )/2;

/* The supplied start and end times are the times at which the SNR peak
   exceeds "dcthresh". We now extend these to include lower SNR values down
   to "dcsiglow". First work downwards from the suppliedstep start until we
   have found "dcnlow" consecutive samples that are below "dcsiglow" sigma. */
      psnr = snr + step->start;
      jtime = step->start;
      count = 0;
      while( --jtime >= 0 ){
         if( ( snrv = *(--psnr) ) != VAL__BADD ) {
            if( fabs( snrv ) < dcsiglow ) {
               if( ++count == dcnlow ) break;
            } else {
               count = 0;
            }
         }
      }

      step_start = jtime + dcnlow;

/* Check that the data prior to the start of the step does not contain
   large sections of identical values in the median-smoothed data. These
   can be caused by sources, and indicate that he step cannot be trusted.  */
      jtime = step_start - 2*dcfitbox;
      if( jtime < 0 ) jtime = 0;
      pw = median + jtime;
      flat_val = VAL__BADD;
      flat_width = 0;
      tol = 0.0;
      bad = 0;

      for( ; jtime < (int) step_start; jtime++,pw++ ){
         if( *pw != VAL__BADD ) {
            if( flat_val == VAL__BADD ){
               flat_val = *pw;
               flat_width = 0;
               tol = 1.0E-10*flat_val;

            } else if( fabs( *pw - flat_val ) > tol ) {
               if( flat_width  > dcflatwidth ) {
                  bad = 1;
                  break;
               }
               flat_val = *pw;
               flat_width = 0;
               tol = 1.0E-10*flat_val;

            } else {
               flat_width++;
            }
         }
      }

/* Now work upwards from the supplied step step end until we have found
   "dcnlow" consecutive samples that are below "dcsiglow" sigma. */
      psnr = snr + step->end;
      jtime = step->end;
      count = 0;
      while( ++jtime < (int) ntslice ){
         if( ( snrv = *(++psnr) ) != VAL__BADD ) {
            if( fabs( snrv ) < dcsiglow ) {
               if( ++count == dcnlow ) break;
            } else {
               count = 0;
            }
         }
      }

      step_end = jtime - dcnlow;

/* Check that the data after the end of the step does not contain
   large sections of identical values in the median-smoothed data. These
   can be caused by sources, and indicate that he step cannot be trusted.  */
      jtime = step_end + 2*dcfitbox;
      if( jtime >= (int) ntslice ) jtime = ntslice - 1;
      pw = median + jtime;
      flat_val = VAL__BADD;
      bad = 0;

      for( ; jtime > (int) step_end; jtime--,pw-- ){
         if( *pw != VAL__BADD ) {
            if( flat_val == VAL__BADD ){
               flat_val = *pw;
               flat_width = 0;
               tol = 1.0E-10*flat_val;

            } else if( fabs( *pw - flat_val ) > tol ) {
               if( flat_width  > dcflatwidth ) {
                  bad = 1;
                  break;
               }
               flat_val = *pw;
               flat_width = 0;
               tol = 1.0E-10*flat_val;

            } else {
               flat_width++;
            }
         }
      }

#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      step->flat = bad;
   }
#endif

      if( !bad ) {

/* Perform linear least squares fits to the median-smoothed data for a
   range of adjacent samples prior to the start of the step found above. */
         jhi = step_start - dcfitbox;
         jlo = jhi - 3*dcfitbox;
         smf_rolling_fit( dcfitbox, 0.1, ntslice, jlo, jhi, median, grad,
                          off, NULL, status );

/* Use each of the fits created above to estimate the data value at the
   centre of the jump, and find the the mean and variance of these
   estimates. */
         sum1 = 0.0;
         sum2 = 0.0;
         nsum = 0;

         pg = grad;
         po = off;
         for( jtime = jlo; jtime <= jhi; jtime++,po++,pg++ ) {
            if( *pg != VAL__BADD && *po != VAL__BADD ) {
               v = ( (int) step_centre - jtime )*( *pg ) + ( *po );
               sum1 += v;
               sum2 += v*v;
               nsum++;
               vlo = v;
            }
         }

         if( nsum > 0 ) {
            vlo_mean = sum1/nsum;
            vlo_var = sum2/nsum - vlo_mean*vlo_mean;
            err0 = vlo - vlo_mean;
            vlo_var += err0*err0;
         } else {
            vlo_mean = VAL__BADD;
            vlo_var = VAL__BADD;
         }

/* Perform linear least squares fits to the median-smoothed data for a
   range of adjacent samples after to the step. */
         jlo = step_end + dcfitbox;
         jhi = jlo + 3*dcfitbox;
         smf_rolling_fit( dcfitbox, 0.1, ntslice, jlo, jhi, median, grad,
                          off, NULL, status );

/* Use each of the fits created above to estimate the data value at the
   centre of the jump, and find the the mean and variance of these
   estimates. */
         sum1 = 0.0;
         sum2 = 0.0;
         nsum = 0;
         vhi = VAL__BADD;

         pg = grad;
         po = off;
         for( jtime = jlo; jtime <= jhi; jtime++,po++,pg++ ) {
            if( *pg != VAL__BADD && *po != VAL__BADD ) {
               v = ( (int) step_centre - jtime )*( *pg ) + ( *po );
               sum1 += v;
               sum2 += v*v;
               nsum++;
               if( vhi == VAL__BADD ) vhi = v;
            }
         }

         if( nsum > 0 ) {
            vhi_mean = sum1/nsum;
            vhi_var = sum2/nsum - vhi_mean*vhi_mean;
            err0 = vhi - vhi_mean;
            vhi_var += err0*err0;
         } else {
            vhi_mean = VAL__BADD;
            vhi_var = VAL__BADD;
         }


#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      step->error = VAL__BADD;
      step->jump = VAL__BADD;
      step->ok = 0;
      step->ibolo = ibolo;
      step->vlo = vlo;
      step->vlo_mean = vlo_mean;
      step->vlo_sigma = ( vlo_var != VAL__BADD ) ? sqrt( vlo_var ) : VAL__BADD;
      step->vhi = vhi;
      step->vhi_mean = vhi_mean;
      step->vhi_sigma = ( vhi_var != VAL__BADD ) ? sqrt( vhi_var ) : VAL__BADD;
   }
#endif

/* Form the total sigma in the jump size. */
         if( vlo_var != VAL__BADD && vhi_var != VAL__BADD ) {
            error = vhi_var + vlo_var;
            error = ( error > 0.0 ) ? sqrt( error ) : 0.0;

/* We prefer the jump estimated from data closer to the step, so get the
   jump height from the closest fit boxes used above. */
            jump = vhi - vlo;

#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      step->error = error;
      step->jump = jump;
   }
#endif

/* Check that the jump is large compared to the uncertainty in jump size
   caused by the variation of the gradient in the neighbourhood of the
   jump. Also check the absolute size of the jump is large enough to be
   usable. */
            if( fabs( jump ) >= dcthresh2*fabs( error ) &&
                fabs( jump ) > step->minjump ) {

#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      step->ok = 1;
   }
#endif

/* Increment the number of fixed steps. */
               result++;

/* Add the current correction onto all data samples since the centre of
   the previous step, up to the centre of the current step. Also
   increment running sums needed to find the mean correction. */
               for( ; itime < step_centre; itime++ ) {
                  if( !(*pq & SMF__Q_MOD )) {
                     *pd += corr;
                     scorr += corr;
                     ncorr++;
                  }
                  pd += tstride;
                  pq += tstride;
               }

/* Set the correction to use up to the next step. */
               corr -= jump;

/* Flag the samples with high SNR. */
               pq2 = qua + step_start*tstride;
               for( jtime = step_start; jtime <= (int) step_end; jtime++ ) {
                   *pq2 |= SMF__Q_JUMP;
                   pq2 += tstride;
               }

/* Increment the number of bolometers that have a step at each time slice. */
               if( bcount ) {
                  for( jtime = step->start; jtime <= (int) step->end; jtime++ ) {
                     bcount[ jtime ]++;
                  }
               }

/* If required, store details of the step in the returned structure. */
               if( steps ) {
                  *steps = astGrow( *steps, ++(*nsteps), sizeof( **steps ) );
                  if( *status == SAI__OK ) {
                     (*steps)[ *nsteps - 1 ].start = step_start;
                     (*steps)[ *nsteps - 1 ].end = step_end;
                     (*steps)[ *nsteps - 1 ].ibolo = ibolo;
                     (*steps)[ *nsteps - 1 ].size = jump;
                     (*steps)[ *nsteps - 1 ].id = *nsteps - 1;
                     (*steps)[ *nsteps - 1 ].corr = 0;
                  }
               }

#ifdef DEBUG_STEPS
   if( RECORD_BOLO2 ) {
      step->ok = 1;
   }
#endif

            }
         }
      }
   }

/* Apply the final correction up to the last sample. */
   if( corr != 0.0 ) {
      for( ; itime < ntslice; itime++ ) {
         if( !(*pq & SMF__Q_MOD )) {
            *pd += corr;
            scorr += corr;
            ncorr++;
         }
         pd += tstride;
         pq += tstride;
      }
   }

/* Now subtract off the mean correction. */
   if( scorr != 0.0 ) {
      mean = scorr/ncorr;
      pd = dat;
      pq = qua;
      for( itime = 0; itime < ntslice; itime++ ) {
         if( !(*pq & SMF__Q_MOD )) *pd -= mean;
         pd += tstride;
         pq += tstride;
      }
   }

/* Return the result */
   return result;
}

