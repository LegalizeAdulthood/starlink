#
# Command file to run a CCDPACK reduction sequence from a
# C shell background job.
#
# set up the global parameters.
#
ccdsetup bounds='[323,349]' rnoise=10 adc=1 extent='[4,318,3,510]' \
         direction=x logto=terminal genvar=true mask=defects.ard \
         reset accept
#
# Add some explanatory notes
#
ccdnote <<FOO
Test run of CCDPACK atasks in background job -
Reduction perform by AUSER on 8-JUN-1992.
FOO
#
# Make the master bias frame.
#
makebias in='bias/*' out=bias/master_bias accept
#
# DEBIAS all the frames. Note using a master bias frame and offsetting
# to the bias strips.
#
debias in='"flatr/*,flatb/*,bdata/*,rdata/*"' out='*_debias' accept
#
# Create the master flat fields for the R and B filters.
#
makeflat in='flatr/*_debias' out='flatr/master_flat' accept
makeflat in='flatb/*_debias' out='flatb/master_flat' accept
#
# Flat field all the appropriate frames.
#
flatcor in='rdata/*_debias' out='*|debias|flattened|' \
        flat=flatr/master_flat accept
flatcor in='bdata/*_debias' out='*|debias|flattened|' \
        flat=flatb/master_flat accept
#
# All done. Add note.
#
ccdnote '"Test reduction finished"'
#
