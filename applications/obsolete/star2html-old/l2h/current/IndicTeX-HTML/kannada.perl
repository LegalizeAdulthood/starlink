# $Id$
# KANNADA.PERL by Ross Moore <ross@mpce.mq.edu.au> 17-1-98
# Mathematics Department, Macquarie University, Sydney, Australia.
#
# Style for LaTeX2HTML v98.1 to construct images of traditional
#  Indic scripts, using:
#
#  Indica pre-processor and sinhala fonts:  sinha, sinhb, sinhc
#    by Yannis Haralambous <Yannis.Haralambous@univ-lille1.fr>
#
#  sinhala.sty  package for LaTeX-2e
#    by Dominik Wujastyk <D.Wujastyk@ucl.ac.uk>
#
#  extended for Prasad Dharmasena's <pkd@isr.umd.edu>
#  `samanala'  transliteration scheme
#    by Vasantha Saparamadu <vsaparam@ocs.mq.edu.au>
#
# These resources are *not* included with this package.
# Obtain them from CTAN:  http//ctan.tug.org/ctan
#
# ===================================================================
# This package requires the corresponding LaTeX package:  kannada.sty .
# It also requiress:  indica.perl  and   indica.sty .
#
# With LaTeX2HTML the options on the \usepackage line specify 
# preprocessor commands to use with Indica.
#
# Usage:
#
#  \usepackage{kannada}            %|  pre-process source using Indica
#  \usepackage[indica]{kannada}    %|  with  #ALIAS KANNADA K
#  \usepackage[preprocess]{kannada}%|  and   #ALIAS NIL N
#
#  \usepackage[kan]{kannada}       %| also use #ALIAS KANNADA KAN
#
#
#  options affecting Input-forms
#
#  \usepackage[7bit]{kannada}    %|  Velthuis' Hindi/Sanskri transcription
#  \usepackage[csx]{kannada}     %|  8-bit Sanskrit extension of ISO 646
#  \usepackage[latex]{kannada}   %|  standardized LaTeX transcription form
#  \usepackage[unicode]{kannada} %|  ISO 10646-1 + Sinhalese extension
#  \usepackage[samanala]{kannada}%|  Prasad Dharmasena's transliteration
#
# ===================================================================
# Warning
#
#  This package works BOTH with source *before* pre-processing
#  and also *after* having pre-processed.
#  The latter may create more smaller images of individual syllabes,
#  whereas the former tends to create larger images of whole lines,
#  paragraphs, sections, etc.
# ===================================================================
#
# Change Log:
# ===========
# $Log$
# Revision 1.1  2004/02/20 13:13:26  nxg
# Initial import
#
# Revision 1.1  1998/01/22 04:33:21  RRM
# 	LaTeX2HTML interfaces to packages and pre-processors for including
# 	traditional Indic scripts (as images) in HTML documents
#
# 	see the .perl files for documentation on usage
# 	see the corresponding .sty file for the LaTeX-2e interface
#
#

package main;


# preprocessor: indica
sub do_kannada_indica { &do_indica_kannada() }
sub do_kannada_preprocess { &do_indica_kannada() }
sub do_kannada_kan { &do_indica_kan() }

# input modes
sub do_kannada_7bit { &do_indica_7bit() }
sub do_kannada_csx { &do_indica_csx() }
sub do_kannada_latex { &do_indica_latex() }
sub do_kannada_unicode { &do_indica_unicode() }
sub do_kannada_samanala { &do_indica_samanala() }


# load Indica for #KANNADA

&do_require_package('indica'); 
if (defined &do_indica_kannada) {
    &do_indica_kannada()
} else { die "\n indica.perl was not loaded, sorry" }

# override Indica variables here
#
#  $INDICA = 'indica';
#  $INDICA_MODE = 'sevenbit';


1;				# Not really necessary...



