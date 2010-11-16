/*
*+
*  Name:
*     smf_write_shortmap

*  Purpose:
*     Write shortmap extension to NDF

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     Library routine

*  Invocation:
*     smf_write_shortmap( int shortmap, smfArray *ast, smfArray *res,
*                         smfArray *lut, smfArray *qua, smfDIMMData *dat,
*                         dim_t msize, const Grp *shortrootgrp,size_t contchunk,
*                         int varmapmethod, const int *lbnd_out,
*                         const int *ubnd_out, AstFrameSet *outfset,
*                         int *status );

*  Arguments:
*     shortmap = int (Given)
*        Number of time slices per short map, or if set to -1, create a map
*        each time TCS_INDEX is incremented (i.e., produce a map each time
*        a full pass through the scan pattern is completed).
*     ast = smfArray* (Given)
*        AST model smfArray
*     res = smfArray* (Given)
*        RES model smfArray
*     lut = smfArray* (Given)
*        LUT model smfArray
*     qua = smfArray* (Given)
*        QUA model smfArray
*     dat = smfDIMMData* (Given)
*        Pointer to additional map-making data passed around in a struct
*     msize = dim_t (Given)
*        Number of pixels in map/mapvar
*     shortrootgrp = const Grp* (Given)
*        Root name for shortmaps. Can be path to HDS container.
*     contchunk = size_t (Given)
*        Continuous chunk number
*     varmapmethod = int (Given)
*        Method for estimating map variance. If 1 use sample variance,
*        if 0 propagate noise from time series.
*     lbnd_out = const int* (Given)
*        2-element array pixel coord. for the lower bounds of the output map
*     ubnd_out = const int* (Given)
*        2-element array pixel coord. for the upper bounds of the output map
*     outfset = AstFrameSet* (Given)
*        Frameset containing the sky->output map mapping
*     status = int* (Given and Returned)
*        Pointer to global status.

*  Description:
*     After the map has converged, create "shortmaps", maps of every
*     shortmap timeslices of data, in an NDF. The root of the name is
*     supplied by shortrootgrp, and the suffix will be CH##SH######,
*     where "CH" is the continuous chunk, and "SH" refers to the
*     shortmap number. The AST and RES data are temporarily combined
*     in this routine before re-gridding into the output map for each
*     shortmap. Upon completion AST is once again subtracted from
*     RES. The following FITS keywords are set to keep track of which
*     portion of the data were used for each shortmap:
*
*       SEQSTART: the RTS index number of first frame
*         SEQEND: the RTS index number of last frame
*        MJD-AVG: the Average MJD of the map
*        TIMESYS: the Time system for MJD-AVG

*  Notes:

*  Authors:
*     EC: Ed Chapin (UBC)
*     {enter_new_authors_here}

*  History:
*     2010-08-20 (EC):
*        Initial version factored out of smf_iteratemap.
*     2010-09-22 (EC):
*        If shortmap=0, create map each time TCS_INDEX increments
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2010 University of British Columbia
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
#include "mers.h"
#include "ndf.h"
#include "sae_par.h"
#include "star/ndg.h"
#include "prm_par.h"
#include "par_par.h"
#include "star/one.h"
#include "star/atl.h"

/* SMURF includes */
#include "libsmf/smf.h"
#include "libsmf/smf_err.h"

#define FUNC_NAME "smf_write_shortmap"

void smf_write_shortmap( int shortmap, smfArray *ast, smfArray *res,
                         smfArray *lut, smfArray *qua, smfDIMMData *dat,
                         dim_t msize, const Grp *shortrootgrp, size_t contchunk,
                         int varmapmethod, const int *lbnd_out,
                         const int *ubnd_out, AstFrameSet *outfset,
                         int *status ) {

  double *ast_data=NULL;        /* Pointer to DATA component of ast */
  dim_t dsize;                  /* Size of data arrays in containers */
  size_t i;                     /* loop counter */
  size_t idx=0;                 /* index within subgroup */
  size_t istart;                /* First useful timeslice */
  size_t iend;                  /* Last useful timeslice */
  size_t k;                     /* loop counter */
  int *lut_data=NULL;           /* Pointer to DATA component of lut */
  char name[GRP__SZNAM+1];      /* Buffer for storing names */
  size_t nshort=0;              /* Number of short maps */
  dim_t ntslice;                /* Number of time slices */
  char *pname=NULL;             /* Poiner to name */
  smf_qual_t *qua_data=NULL;    /* Pointer to DATA component of qua */
  double *res_data=NULL;        /* Pointer to DATA component of res */
  size_t sc;                    /* Short map counter */
  double *shortmapweight=NULL;  /* buffer for shotmap weights */
  double *shortmapweightsq=NULL;/* buffer for shotmap weights squared */
  int *shorthitsmap=NULL;       /* buffer for shotmap hits */
  size_t shortstart;            /* first time slice of short map */
  size_t shortend;              /* last time slice of short map */
  size_t tstride;               /* Time stride */

  if( *status != SAI__OK ) return;

  if( !ast || !res || !lut || !qua || !dat || !shortrootgrp ||
      !lbnd_out || !ubnd_out || !outfset || !shortmap ) {
    *status = SAI__ERROR;
    errRep( "", FUNC_NAME ": NULL inputs supplied", status );
    return;
  }


  if( !res || !res->sdata || !res->sdata[idx] || !res->sdata[idx]->hdr ||
      !res->sdata[idx]->hdr->allState ) {
    *status = SAI__ERROR;
    errRep( "", FUNC_NAME ": RES does not contain JCMTState", status );
    return;
  }

  /* Allocate space for the arrays */
  shortmapweight = astCalloc( msize, sizeof(*shortmapweight), 0 );
  shortmapweightsq = astCalloc( msize, sizeof(*shortmapweightsq), 0 );
  shorthitsmap = astCalloc( msize, sizeof(*shorthitsmap), 0 );

  /* Use first subarray to figure out time dimension. Get the
     useful start and end points of the time series, and then
     determine "nshort" -- the number of complete blocks of
     shortmap time slices in the useful range. */

  smf_get_dims( qua->sdata[0], NULL, NULL, NULL, &ntslice,
                NULL, NULL, &tstride, status );

  qua_data = (qua->sdata[0]->pntr)[0];
  smf_get_goodrange( qua_data, ntslice, tstride, SMF__Q_BOUND,
                     &istart, &iend, status );

  shortstart = istart;

  if( *status == SAI__OK ) {
    if( shortmap == -1 ) {
      nshort = res->sdata[idx]->hdr->allState[iend].tcs_index -
        res->sdata[idx]->hdr->allState[istart].tcs_index + 1;

      msgOutf( "", FUNC_NAME
               ": writing %zu short maps, once each time TCS_INDEX increments",
               status, nshort );
    } else {
      nshort = (iend-istart+1)/shortmap;

      if( nshort ) {
        msgOutf( "", FUNC_NAME
                 ": writing %zu short maps of length %i time slices.",
                 status, nshort, shortmap );
      } else {
        /* Generate warning message if requested short maps are too long*/
        msgOutf( "", FUNC_NAME
                 ": Warning! short maps of lengths %i requested, but "
                 "data only %zu time slices.", status, shortmap,
                 iend-istart+1 );
      }
    }
  }

  /* Loop over short maps */
  for( sc=0; (sc<nshort)&&(*status==SAI__OK); sc++ ) {

    Grp *mgrp=NULL;             /* Temporary group for map names */
    smfData *mapdata=NULL;      /* smfData for new map */
    char tempstr[20];           /* Temporary string */
    char tmpname[GRP__SZNAM+1]; /* temp name buffer */
    char thisshort[20];         /* name particular to this shortmap */

    /* Create a name for the new map, take into account the
       chunk number. Only required if we are using a single
       output container. */
    pname = tmpname;
    grpGet( shortrootgrp, 1, 1, &pname, sizeof(tmpname), status );
    one_strlcpy( name, tmpname, sizeof(name), status );
    one_strlcat( name, ".", sizeof(name), status );

    /* Continuous chunk number */
    sprintf(tempstr, "CH%02zd", contchunk);
    one_strlcat( name, tempstr, sizeof(name), status );

    /* Shortmap number */
    sprintf( thisshort, "SH%06zu", sc );
    one_strlcat( name, thisshort, sizeof(name), status );
    mgrp = grpNew( "shortmap", status );
    grpPut1( mgrp, name, 0, status );

    msgOutf( "", "*** Writing short map (%zu / %zu) %s", status,
             sc+1, nshort, name );

    smf_open_newfile ( mgrp, 1, SMF__DOUBLE, 2, lbnd_out,
                       ubnd_out, SMF__MAP_VAR, &mapdata,
                       status);

    /* Loop over subgroup index (subarray) -- only continue if
       nshort > 0! */

    for( idx=0; (idx<res->ndat)&&(nshort)&&(*status==SAI__OK);
         idx++ ){
      int rebinflag = 0;

      /* Pointers to everything we need */
      ast_data = (ast->sdata[idx]->pntr)[0];
      res_data = (res->sdata[idx]->pntr)[0];
      lut_data = (lut->sdata[idx]->pntr)[0];
      qua_data = (qua->sdata[idx]->pntr)[0];

      smf_get_dims( res->sdata[idx], NULL, NULL, NULL, &ntslice,
                    &dsize, NULL, &tstride, status );

      /* Add ast back into res. Mask should match ast_calcmodel_ast. */
      for( k=0; k<dsize; k++ ) {
        if( !(qua_data[k]&SMF__Q_MOD) && (ast_data[k]!=VAL__BADD) ) {
          res_data[k] += ast_data[k];
        }
      }

      /* Rebin the data for this range of tslices. */
      if( idx == 0 ) {
        rebinflag |= AST__REBININIT;
      }

      if( idx == (res->ndat-1) ) {
        rebinflag |= AST__REBINEND;
      }

      /* Time slices indices for start and end of short map */
      if( shortmap > 0) {
        /* Evenly-spaced shortmaps in time */
        shortstart = istart+sc*shortmap;
        shortend = istart+(sc+1)*shortmap-1;
      } else {
        /* One map each time TCS_INDEX increments */
        for(i=shortstart+1; (i<=iend) &&
              (res->sdata[idx]->hdr->allState[i].tcs_index ==
               res->sdata[idx]->hdr->allState[shortstart].tcs_index);
            i++ );
        shortend = i-1;
      }

      smf_rebinmap1( res->sdata[idx],
                     dat->noi ? dat->noi[0]->sdata[idx] : NULL,
                     lut_data, shortstart, shortend, 1, NULL, 0,
                     SMF__Q_GOOD, varmapmethod,
                     rebinflag,
                     mapdata->pntr[0],
                     shortmapweight, shortmapweightsq, shorthitsmap,
                     mapdata->pntr[1], msize, NULL, NULL, status );

      /* Remove ast from res once again */
      for( k=0; k<dsize; k++ ) {
        if( !(qua_data[k]&SMF__Q_MOD) && (ast_data[k]!=VAL__BADD) ) {
          res_data[k] -= ast_data[k];
        }
      }

      /* Write out FITS header */
      if( (*status == SAI__OK) && res->sdata[idx]->hdr &&
          res->sdata[idx]->hdr->allState ) {
        AstFitsChan *fitschan=NULL;
        JCMTState *allState = res->sdata[idx]->hdr->allState;
        size_t midpnt = (shortstart + shortend) / 2;

        fitschan = astFitsChan ( NULL, NULL, " " );

        atlPtfti( fitschan, "SEQSTART", allState[shortstart].rts_num,
                  "RTS index number of first frame", status );
        atlPtfti( fitschan, "SEQEND", allState[shortend].rts_num,
                  "RTS index number of last frame", status);
        atlPtftd( fitschan, "MJD-AVG", allState[midpnt].rts_end,
                  "Average MJD of this map", status );
        atlPtfts( fitschan, "TIMESYS", "TAI", "Time system for MJD-AVG",
                  status );
        atlPtfti( fitschan, "TCSINDST", allState[shortstart].tcs_index,
                  "TCS index of first frame", status );
        atlPtfti( fitschan, "TCSINDEN", allState[shortend].tcs_index,
                  "TCS index of last frame", status );


        kpgPtfts( mapdata->file->ndfid, fitschan, status );

        if( fitschan ) fitschan = astAnnul( fitschan );
      }

      /* Update shortstart in case we are counting steps in TCS_INDEX */
      shortstart = shortend+1;
    }

    /* Write WCS */
    smf_set_moving(outfset,status);
    ndfPtwcs( outfset, mapdata->file->ndfid, status );

    /* Clean up */
    if( mgrp ) grpDelet( &mgrp, status );
    smf_close_file( &mapdata, status );

  }

  /* Free up memory */
  if( shortmapweight ) shortmapweight = astFree( shortmapweight );
  if( shortmapweightsq ) shortmapweightsq = astFree( shortmapweightsq );
  if( shorthitsmap ) shorthitsmap = astFree( shorthitsmap );

}
