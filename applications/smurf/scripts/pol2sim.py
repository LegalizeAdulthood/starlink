#!/usr/bin/env python

'''
*+
*  Name:
*     POL2SIM

*  Purpose:
*     Create simulated POL2 data from known I, Q and U maps

*  Language:
*     python (2.7 or 3.*)

*  Description:
*     This script creates simulated POL2 time-series data, using a
*     supplied real POL2 observation as a template. The maps containing
*     the artificial I, Q and U values at each point on the sky can be
*     created automatically, or can be supplied by the user (see
*     parameters ARTI, ARTQ and ARTU).
*
*     There are two basic modes of operation, selected by the parameter
*     ADDON:
*
*     - If ADDON is True, noise-free artificial POL2 time-stream data is
*     generated by sampling supplied I, Q and U maps at the position of
*     each bolometer value in the supplied real POL2 observation, and the
*     artificial time-stream data is then added onto the real time-stream
*     data to generate the output time-streams. In this mode, no artificial
*     noise components are added into the artificial time-stream data.
*     Instead, the noise in the output time-streams is inherited from the
*     noise in the input real POL2 time-streams
*
*     - If ADDON is False, artificial POL2 time-stream data is generated
*     in the same way, but is then used directly as the output time-sreams
*     without first adding on the real time-stream data. In this mode,
*     artificial noise components are added into the artificial time-stream
*     data as follows (NOTE - this mode takes a very long time to run !!):
*
*     o A  time-varying unpolarised sky brightness is added onto the
*       I values amapled from the supplied ARTI map. The sky brightness
*       is common to all bolometers, and is derived from the time-series
*       data for a a real scan map (see parameter INCOM). For some
*       unknown reason, the common-mode for real POL2 data seems to be much
*       flatter than the common-mode for real non-POL2 data. For this
*       reason, there is an option to flatten the common-mode before using
*       it in the simulation (see parameter CFACTOR).
*     o 2, 4 and 16 Hz signals proportional to the total intensity (including
*       sky brightness) in included in the simulated POL2 data.
*     o Each bolometer has a separate gain, which is allowed to vary over
*       time (like the GAI model used by smurf:makemap). The GAI values
*       are derived from the template POL2 data supplied for parameter
*       IN. The extent to which the GAI values vary with time is controlled
*       by parameter GFACTOR
*     o Random Gaussian noise is added to the returned time-stream data.
*
*     In both modes, instrumental polarisation is included in the
*     artificial time-stream data (see parameter IPFORM). Three forms of
*     instrumental polarisation can be used: the Johnstone/Kennedy IPDATA
*     model, the simplified planetary data "PL1" model, or an arbitrary
*     user-define IP model (see parameters IPMAX, IPMIN and IPTHETA).

*  Usage:
*     pol2sim in out newart arti artq artu

*  ADAM Parameters:
*     ADDON = _LOGICAL (Read)
*        If True, the output time-stream data consists of the sum of the
*        artificial time-stream data (generated by sampling the maps
*        given by parameters ARTI, ARTQ and ARTU) and the real time-stream
*        data (given by parameter IN). If False, the output time-stream
*        data consists just of the artificial data. [False]
*     AMP2 = _DOUBLE (Read)
*        Controls the amplitude of the 2 Hz signal. It gives the amplitude
*        of the 2 Hz signal as a fraction of the total intensity. See
*        also "PHASE2". Only used if ADDON is False. [0.0003]
*     AMP4 = _DOUBLE (Read)
*        Controls the amplitude of the 4 Hz signal. It gives the amplitude
*        of the 4 Hz signal as a fraction of the total intensity. See
*        also "PHASE4". Only used if ADDON is False. [0.009]
*     AMP16 = _DOUBLE (Read)
*        Controls the amplitude of the 16 Hz signal. It gives the amplitude
*        of the 16 Hz signal as a fraction of the total intensity. See
*        also "PHASE16". Only used if ADDON is False. [0.0008]
*     ARTI = NDF (Read or write)
*        A 2D NDF holding the artificial total intensity map from which the
*        returned time-stream data is derived. If the NEWART parameter
*        is True, then a new artificial I map is created and stored in
*        a new NDF with name specified by ARTI. If NEWART is False, then
*        ARTI should specify an existing NDF on entry, which is used as
*        the artificial I map.
*     ARTQ = NDF (Read or write)
*        A 2D NDF holding the artificial Q map from which the returned
*        time-stream data is derived. If the NEWART parameter is True, then
*        a new artificial Q map is created and stored in a new NDF with name
*        specified by ARTQ. If NEWART is False, then ARTQ should specify an
*        existing NDF on entry, which is used as the artificial Q map.
*     ARTU = NDF (Read or write)
*        A 2D NDF holding the artificial U map from which the returned
*        time-stream data is derived. If the NEWART parameter is True, then
*        a new artificial U map is created and stored in a new NDF with name
*        specified by ARTU. If NEWART is False, then ARTU should specify an
*        existing NDF on entry, which is used as the artificial U map.
*     CFACTOR = _DOUBLE (Read)
*        A factor by which to expand the COM model values derived from
*        the supplied INCOM data. The expansion is centred on the mean
*        value. Real POL2 data seems to have a much flatter common-mode
*        than real non-POL2 data, so the default flattens the common-mode
*        to some extent. Only used if ADDON is False. [0.2]
*     COMVAL1 = _DOUBLE (Read)
*        Only used if ADDON is False and INCOM is null (!). If supplied,
*	 COMVAL1 should be a constant sky emission value in pW seen by all
*        bolometers and time slices. The total common-mode signal added
*        to the simulated data is the sum of COMVAL1 and COMVAL2, but
*        only COMVAL1 is considered when determing the Q and U values
*        caused by Instrumental Polarisation. Supplying null (!) is
*        equivalent to supplying zero. [0.0]
*     COMVAL2 = _DOUBLE (Read)
*        Only used if ADDON is False and INCOM is null (!). If supplied,
*	 COMVAL2 should be a constant offset to add to all bolometers and
*        time slices representing an offset in the electronics (i.e. not
*        caused by sky emission). The total common-mode signal added
*        to the simulated data is the sum of COMVAL1 and COMVAL2, but
*        only COMVAL1 is considered when determing the Q and U values
*        caused by Instrumental Polarisation. Supplying null (!) is
*        equivalent to supplying zero. [0.0]
*     GFACTOR = _DOUBLE (Read)
*        A factor by which to expand the GAI model values derived from
*        the supplied time-series data. The expansion is centred on the
*        value 1.0. No GAI model is used if GFACTOR is zero. Only used if
*        ADDON is False and INCOM is not null (!). [1.0]
*     GLEVEL = LITERAL (Read)
*        Controls the level of information to write to a text log file.
*        Allowed values are as for "ILEVEL". The log file to create is
*        specified via parameter "LOGFILE. In adition, the glevel value
*        can be changed by assigning a new integer value (one of
*        starutil.NONE, starutil.CRITICAL, starutil.PROGRESS,
*        starutil.ATASK or starutil.DEBUG) to the module variable
*        starutil.glevel. ["ATASK"]
*     IFWHM = _DOUBLE (Read)
*        FWHM of Gaussian source for new artificial total instensity map,
*        in pixels. [8]
*     ILEVEL = LITERAL (Read)
*        Controls the level of information displayed on the screen by the
*        script. It can take any of the following values (note, these values
*        are purposefully different to the SUN/104 values to avoid confusion
*        in their effects):
*
*        - "NONE": No screen output is created
*
*        - "CRITICAL": Only critical messages are displayed such as warnings.
*
*        - "PROGRESS": Extra messages indicating script progress are also
*        displayed.
*
*        - "ATASK": Extra messages are also displayed describing each atask
*        invocation. Lines starting with ">>>" indicate the command name
*        and parameter values, and subsequent lines hold the screen output
*        generated by the command.
*
*        - "DEBUG": Extra messages are also displayed containing unspecified
*        debugging information. In addition scatter plots showing how each Q
*        and U image compares to the mean Q and U image are displayed at this
*        ILEVEL.
*
*        In adition, the glevel value can be changed by assigning a new
*        integer value (one of starutil.NONE, starutil.CRITICAL,
*        starutil.PROGRESS, starutil.ATASK or starutil.DEBUG) to the module
*        variable starutil.glevel. ["PROGRESS"]
*     IN = NDF (Read)
*        A group of POL2 time series NDFs.
*     INCOM = NDF (Read)
*        A group of non-POL2 time series NDFs that are used to define
*        the common-mode (i.e. the sky brightness) to include in the
*        simulated POL2 data. The number of NDFs supplied for INCOM must
*        equal the number supplied for IN. Each INCOM file must be at least
*        as long (in time) as the corresponding IN file. If null (!) is
*        supplied, the common-mode is defined by parameters COMVAL1 and
*        COMVAL2 instead. Only used if ADDON is False. [!]
*     IPFORM = LITERAL (Read)
*        The form of instrumental polarisation to use. Can be "JK" for the
*        Johnstone/Kennedy model, "PL1" for the simplified planetary data model,
*        "User" for a user-defined model (see parameters IPMAX, IPMIN and
*        IPTHETA), or "None" if no instrumental polarisation is to be added
*        to the simulated data. ["PL1"]
*     IPEAK = _DOUBLE (Read)
*        Peak intensity for new artificial total instensity map, in pW. [0.08]
*     IPMIN = _DOUBLE (Read)
*        The minimum instrumental polarisation within the focal plane,
*        expressed as a fraction. The IP varies linearly across each
*        array from IPMIN to IPMAX. The IP is fixed in focal plane
*        coordinates over all stare positions. This parameter is only
*        accessed if IPFORM is set to "User". [0.0004]
*     IPMAX = _DOUBLE (Read)
*        The maximum instrumental polarisation within the focal plane,
*        expressed as a fraction. The IP varies linearly across each
*        array from IPMIN to IPMAX. The IP is fixed in focal plane
*        coordinates over all stare positions. This parameter is only
*        accessed if IPFORM is set to "User". [0.0008]
*     IPTHETA = _DOUBLE (Read)
*        The angle from the focal plane Y axis to the instrumental
*        polarisation vectors, in degrees. This parameter is only
*        accessed if IPFORM is set to "User". [15]
*     LOGFILE = LITERAL (Read)
*        The name of the log file to create if GLEVEL is not NONE. The
*        default is "<command>.log", where <command> is the name of the
*        executing script (minus any trailing ".py" suffix), and will be
*        created in the current directory. Any file with the same name is
*        over-written. The script can change the logfile if necessary by
*        assign the new log file path to the module variable
*        "starutil.logfile". Any old log file will be closed befopre the
*        new one is opened. []
*     MSG_FILTER = LITERAL (Read)
*        Controls the default level of information reported by Starlink
*        atasks invoked within the executing script. This default can be
*        over-ridden by including a value for the msg_filter parameter
*        within the command string passed to the "invoke" function. The
*        accepted values are the list defined in SUN/104 ("None", "Quiet",
*        "Normal", "Verbose", etc). ["Normal"]
*     NEWART = _LOGICAL (Read)
*        Indicates if new artificial I, Q and U maps should be created.
*        These are the maps from which the returned time-stream data are
*        derived.
*
*        If NEWART is False, then existing 2D NDFs holding the artificial
*        I, Q and U data to be used should be specified via parameter ARTI,
*        ARTQ and ARTU. These maps should have WCS that is consistent with
*        the supplied template time-stream data (parameter IN). The data
*        values are assumed to be in units of "pW". The Y pixel axis is
*        assumed to be the polarimetric reference direction.
*
*        If NEWART is True, then new artificial I, Q and U data is
*        created representing a single Gaussian source centred at pixel
*        coordinates given by parameters XC and YC (default is (0,0)), with
*        peak total intensity given by parameter IPEAK and width given by
*        parameter IFWHM. The polarisation vectors are tangential, centred on
*        the source. The fractional polarisation is constant at the value
*        given by POL. The Y pixel axis is reference direction (suitable
*        POLANAL Frames are included in the WCS to indicate this, as
*        required by POLPACK).
*     OUT = NDF (Write)
*        A group of output NDFs to hold the simulated POL2 time series
*        data. Equal in number to the files in "IN".
*     PHASE2 = _DOUBLE (Read)
*        The phase offset to apply to the 2 Hz signal specified via
*        parameter AMP2, in degrees. Only used if ADDON is False. [0.0]
*     PHASE4 = _DOUBLE (Read)
*        The phase offset to apply to the 4 Hz signal specified via
*        parameter AMP4, in degrees. Only used if ADDON is False. [-30.0]
*     PHASE16 = _DOUBLE (Read)
*        The phase offset to apply to the 16 Hz signal specified via
*        parameter AMP16, in degrees. Only used if ADDON is False. [0.0]
*     POL = _DOUBLE (Read)
*        The fractional polarisation for new artificial Q and U maps.
*        [0.05]
*     RESTART = LITERAL (Read)
*        If a value is assigned to this parameter, it should be the path
*        to a directory containing the intermediate files created by a
*        previous run of POL2SIM (it is necessry to run POL2SIM with
*        RETAIN=YES otherwise the directory is deleted after POL2SIM
*        terminates). If supplied, any files which can be re-used from
*        the supplied directory are re-used, thus speeding things up.
*        The path to the intermediate files can be found by examining the
*        log file created by the previous run. [!]
*     RETAIN = _LOGICAL (Read)
*        Should the temporary directory containing the intermediate files
*        created by this script be retained? If not, it will be deleted
*        before the script exits. If retained, a message will be
*        displayed at the end specifying the path to the directory. [FALSE]
*     SIGMA = _DOUBLE (Read)
*        Gaussian noise level (in pW) to add to the final data. Only used
*        if ADDON is False. [0.004]
*     XC = _DOUBLE (Read)
*        The X pixel coordinate at which to place the artificial blob if
*        NEWART is YES. [0.0]
*     YC = _DOUBLE (Read)
*        The Y pixel coordinate at which to place the artificial blob if
*        NEWART is YES. [0.0]

*  Copyright:
*     Copyright (C) 2015 East Asian Observatory
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either Version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
*     02110-1301, USA.

*  Authors:
*     DSB: David S. Berry (EAO)
*     {enter_new_authors_here}

*  History:
*     4-MAY-2015 (DSB):
*        Original version
*     20-SEP-2015 (DSB):
*        - Base names of output NDFs on the names of the flatfielded
*        NDFs, rather than the supplied input NDFs. This is because
*        the input NDFs include non-science files (flatfields, darks,
*        etc). This bug caused pol2sim to loose track of sub-scan numbers
*        when processing data form multiple subarrays.
*        - Added parameter ADDON.
*        - Add azel pointing correction for old data.
*        - Added parameters XC and YC.
*     3-DEC-2015 (DSB):
*        - Add support for PL1 IP model.
*        - Remove IPDATA parameter.
*     2-JUN-2016 (DSB):
*        Replaced parameter COMVAL with COMVAL1 and COMVAL2.
*-
'''

import os
import re
import math
import starutil
from starutil import invoke
from starutil import NDG
from starutil import Parameter
from starutil import ParSys
from starutil import msg_out
from starutil import UsageError

#  Assume for the moment that we will not be retaining temporary files.
retain = 0

#  Assume for the moment that we will not be re-using old temporary files.
restart = None

#  A function to clean up before exiting. Delete all temporary NDFs etc,
#  unless the script's RETAIN parameter indicates that they are to be
#  retained. Also delete the script's temporary ADAM directory.
def cleanup():
   global retain
   ParSys.cleanup()
   if retain:
      msg_out( "Retaining temporary files in {0}".format(NDG.tempdir))
   else:
      NDG.cleanup()

#  Catch any exception so that we can always clean up, even if control-C
#  is pressed.
try:

#  Declare the script parameters. Their positions in this list define
#  their expected position on the script command line. They can also be
#  specified by keyword on the command line. No validation of default
#  values or values supplied on the command line is performed until the
#  parameter value is first accessed within the script, at which time the
#  user is prompted for a value if necessary. The parameters "MSG_FILTER",
#  "ILEVEL", "GLEVEL" and "LOGFILE" are added automatically by the ParSys
#  constructor.
   params = []

   params.append(starutil.ParNDG("IN", "Template POL2 time series NDFs",
                                 starutil.get_task_par("DATA_ARRAY","GLOBAL",
                                                       default=Parameter.UNSET)))
   params.append(starutil.Par0S("OUT", "Output simulated POL2 data"))
   params.append(starutil.Par0L("NEWART", "Create new artificial I, Q and U maps?" ))
   params.append(starutil.ParNDG("ARTI", "Artificial I map", maxsize=1 ))
   params.append(starutil.ParNDG("ARTQ", "Artificial Q map", maxsize=1 ))
   params.append(starutil.ParNDG("ARTU", "Artificial U map", maxsize=1 ))
   params.append(starutil.ParNDG("INCOM", "Non-POL2 data files to define COM",
                                 None, noprompt=True ))
   params.append(starutil.Par0F("COMVAL1", "Constant sky emission (pW)",
                                 0.0, noprompt=True ))
   params.append(starutil.Par0F("COMVAL2", "Constant electronic offset (pW)",
                                 0.0, noprompt=True ))
   params.append(starutil.Par0S("RESTART", "Restart using old files?", None,
                                 noprompt=True))
   params.append(starutil.Par0L("RETAIN", "Retain temporary files?", False,
                                 noprompt=True))
   params.append(starutil.Par0F("IPEAK", "Peak total instensity in "
                                "artificial I map (pW)", 0.08, True ))
   params.append(starutil.Par0F("IFWHM", "Width of source in artificial I "
                                "map (pixels)", 8, True ))
   params.append(starutil.Par0F("POL", "Fractional polarisation in "
                                "artificial Q/U maps", 0.05, True ))
   params.append(starutil.ParChoice("IPFORM", ['JK', 'PL1', 'User', 'None'],
                                "The form of instrumental polarisation "
                                "to add to the simulated data", "PL1", True ))
   params.append(starutil.Par0F("IPMAX", "Maximum fractional instrumental "
                                "polarisation", 0.0008, True ))
   params.append(starutil.Par0F("IPMIN", "Minimum fractional instrumental "
                                "polarisation", 0.0004, True ))
   params.append(starutil.Par0F("IPTHETA", "Angle for for instrumental "
                                "polarisation (deg.s)", 15.0, True ))
   params.append(starutil.Par0F("GFACTOR", "Expansion factor for GAI values",
                                1.0, True ))
   params.append(starutil.Par0F("CFACTOR", "Expansion factor for COM values",
                                0.2, True ))
   params.append(starutil.Par0F("AMP2", "Amplitude for 2Hz signal",
                                0.0003, True ))
   params.append(starutil.Par0F("AMP4", "Amplitude for 4Hz signal",
                                0.009, True ))
   params.append(starutil.Par0F("AMP16", "Amplitude for 16Hz signal",
                                0.0008, True ))
   params.append(starutil.Par0F("PHASE2", "Phase for 2Hz signal (deg.s)",
                                0.0, True ))
   params.append(starutil.Par0F("PHASE4", "Phase for 4Hz signal (deg.s)",
                                -30.0, True ))
   params.append(starutil.Par0F("PHASE16", "Phase for 16Hz signal (deg.s)",
                                0.0, True ))
   params.append(starutil.Par0F("SIGMA", "Noise level in pW", 0.004, True ))
   params.append(starutil.Par0L("ADDON", "Add artificial and real time-stream data?",
                                False, noprompt=True))
   params.append(starutil.Par0F("XC", "X pixel coord at blob centre",
                                0.0, True ))
   params.append(starutil.Par0F("YC", "Y pixel coord at blob centre",
                                0.0, True ))

#  Initialise the parameters to hold any values supplied on the command
#  line.
   parsys = ParSys( params )

#  It's a good idea to get parameter values early if possible, in case
#  the user goes off for a coffee whilst the script is running and does not
#  see a later parameter propmpt or error...

#  Get the template POL2 data files. They should be supplied as the first
#  item on the command line, in the form of a Starlink "group expression"
#  (i.e.the same way they are supplied to other SMURF commands such as
#  makemap). Quote the string so that it can be used as command line
#  argument when running an atask from the shell.
   indata = parsys["IN"].value

#  AZ/EL pointing correction, for pre 20150929 data.
   if int(starutil.get_fits_header( indata[0], "UTDATE", True )) < 20150929:
      pntfile = os.path.join(NDG.tempdir,"pointing")
      fd = open(pntfile,"w")
      fd.write("# system=azel\n")
      fd.write("# tai dlon dlat\n")
      fd.write("54000 32.1 27.4\n")
      fd.write("56000 32.1 27.4\n")
      fd.close()
   else:
      pntfile = "!"

#  Are we inheriting noise from the input (real) time-streams, rather
#  than generating artificial noise?
   addon = parsys["ADDON"].value

#  Common mode files.
   if addon:
      incom = None
      comval1 = 0.0
      comval2 = 0.0
   else:
      incom = parsys["INCOM"].value
      if not incom:
         comval1 = parsys["COMVAL1"].value
         comval2 = parsys["COMVAL2"].value
      else:
         comval1 = 0.0
         comval2 = 0.0

   if incom:
      if len(incom) < len(indata):
         raise UsageError("\n\nInsufficient files supplied for INCOM - "
                          "must be at least {0}.".format(len(indata)))

#  Do not use more com files for each sub-array than are needed.
      remlist = []
      for subarr in ( "s8a", "s8b", "s8c", "s8d", "s4a", "s4b", "s4c", "s4d" ):
         nin = 0
         for ndf in indata:
            if subarr in ndf:
               nin += 1

         ncom = 0
         for ndf in incom:
            if subarr in ndf:
               ncom += 1
               if ncom > nin:
                  remlist.append( ndf )

      msg_out("Ignoring {0} surplus files in INCOM".format(len(remlist) ))
      for ndf in remlist:
        incom.remove( ndf )

#  See if new artificial I, Q and U maps are to be created.
   newart = parsys["NEWART"].value

#  If not, set the ART parameters to indicate that the specified NDFs
#  must already exist.
   if not newart:
      parsys["ARTI"].exists = True
      parsys["ARTQ"].exists = True
      parsys["ARTU"].exists = True
   else:
      parsys["ARTI"].exists = False
      parsys["ARTQ"].exists = False
      parsys["ARTU"].exists = False

#  Get the ART maps.
   iart = parsys["ARTI"].value
   qart = parsys["ARTQ"].value
   uart = parsys["ARTU"].value

#  Other required params
   if not addon:
      amp2 = parsys["AMP2"].value
      phase2 = parsys["PHASE2"].value
      amp4 = parsys["AMP4"].value
      phase4 = parsys["PHASE4"].value
      amp16 = parsys["AMP16"].value
      phase16 = parsys["PHASE16"].value
      sigma = parsys["SIGMA"].value
   else:
      amp2 = 0.0
      phase2 = 0.0
      amp4 = 0.0
      phase4 = 0.0
      amp16 = 0.0
      phase16 = 0.0
      sigma = 0.0

#  See if old temp files are to be re-used.
   restart = parsys["RESTART"].value
   if restart is None:
      retain = parsys["RETAIN"].value
      indata.save( "IN" )

   else:
      retain = True
      NDG.tempdir = restart
      if not os.path.isdir(restart):
         raise UsageError("\n\nThe directory specified by parameter RESTART ({0}) "
                          "does not exist".format(restart) )
      fred = NDG.load( "IN", True )
      if indata != fred:
         raise UsageError("\n\nThe directory specified by parameter RESTART ({0}) "
                          "refers to different time-series data".format(restart) )
      msg_out( "Re-using data in {0}".format(restart) )

#  Initialise the starlink random number seed to a known value so that
#  results are repeatable.
   os.environ["STAR_SEED"] = "65"

#  Flat field the supplied template data
   ff = NDG.load( "FF" )
   if not ff:
      ffdir = NDG.subdir()
      msg_out( "Flatfielding template data...")
      invoke("$SMURF_DIR/flatfield in={0} out=\"{1}/*\"".format(indata,ffdir) )
      ff = NDG("{0}/\*".format(ffdir))
      ff.save( "FF" )
   else:
      msg_out( "Re-using old flatfielded template data...")

#  Output files. Base the modification on "ff" rather than "indata",
#  since "indata" may include non-science files (flatfields, darks etc)
#  for which no corresponding output file should be created.
   gexp = parsys["OUT"].value
   outdata = NDG( ff, gexp )

#  If required, create new artificial I, Q and U maps.
   if newart:
      msg_out( "Creating new artificial I, Q and U maps...")

#  Get the parameters defining the artificial data
      ipeak = parsys["IPEAK"].value
      ifwhm = parsys["IFWHM"].value
      xc = parsys["XC"].value
      yc = parsys["YC"].value
      pol = parsys["POL"].value

#  Make a junk map from the reference data. This is just to define the
#  WCS for the artifical I,Q,U maps. The data values in the map are not used.
      conf = os.path.join(NDG.tempdir,"junkconf")
      fd = open(conf,"w")
      fd.write("doclean=0\n")
      fd.write("numiter=1\n")
      fd.write("modelorder=(ast)\n")
      fd.write("flagslow=0.01\n")
      fd.write("downsampscale=0\n")
      fd.close()
      junk = NDG(1)
      invoke("$SMURF_DIR/makemap in={0} out={1} config=^{2}".format(ff,junk,conf))
      pixsize = starutil.get_task_par( "pixsize", "makemap" )
      lx = int( starutil.get_task_par( "lbnd(1)", "makemap" ))
      ly = int( starutil.get_task_par( "lbnd(2)", "makemap" ))
      ux = int( starutil.get_task_par( "ubnd(1)", "makemap" ))
      uy = int( starutil.get_task_par( "ubnd(2)", "makemap" ))

#  Expand them by some safety margin.
      delta = ( ux - lx )/10
      lx -= delta
      ux += delta
      delta = ( uy - ly )/10
      ly -= delta
      uy += delta

#  Ensure they are integers so that they are interpreted as integer
#  pixel indices rather than WCS axis values.
      lx = int( round( lx ) )
      ux = int( round( ux ) )
      ly = int( round( ly ) )
      uy = int( round( uy ) )

#  Generate Q,U and I for a single gaussian bump.  Tangential vectors
#  centred on the bump, with increasing percentage polarisation at larger
#  radii. Y pixel axis is reference direction. First create the I map.
      if ipeak != 0.0:
         invoke("$KAPPA_DIR/maths exp=\"'ia*0+pa*exp(-pc*((xa-px)**2+(xb-py)**2)/(pf**2))'\" "
                "pa={0} pc=1.66511 pf={1} out={2} px={3} py={4} "
                "ia={5}'({6}:{7},{8}:{9})'".
                format(ipeak,ifwhm,iart,xc,yc,junk,lx,ux,ly,uy))

#  Copy the WCS from the junk map. */
         invoke("$KAPPA_DIR/wcscopy ndf={0} like={1}'(,)' ok=yes".format(iart,junk) )

#  Now create the fractional polarisation map.
         fp = NDG(1)
         invoke("$KAPPA_DIR/maths exp=\"'ia*0+pa'\" ia={0} out={1} pa={2}".
                format(iart,fp,pol) )

#  Polarised intensity.
         pi = NDG(1)
         invoke( "$KAPPA_DIR/mult in1={0} in2={1} out={2}".format(iart,fp,pi) )

#  Get q and u values that give radial vectors.
         theta = NDG(1)
         invoke( "$KAPPA_DIR/maths exp=\"'ia*0+atan2(-(xa-px),(xb-py))'\" "
                 "ia={0} out={1} px={2} py={3}".format(iart,theta,xc,yc) )
         invoke("$KAPPA_DIR/maths exp=\"'-ia*cos(2*ib)'\" ia={0} ib={1} out={2}".format(pi,theta,qart) )
         invoke("$KAPPA_DIR/maths exp=\"'-ia*sin(2*ib)'\" ia={0} ib={1} out={2}".format(pi,theta,uart) )

#  Fill I, Q and U images with zeros if IPEAK is zero.
      else:
         invoke("$KAPPA_DIR/creframe mode=fl mean=0 lbound=\[{0},{1}\] "
                "ubound=\[{2},{3}\] out={4}".format(lx,ly,ux,uy,iart))
         invoke("$KAPPA_DIR/wcscopy ndf={0} like={1}'(,)' ok=yes".format(iart,junk) )
         invoke("$KAPPA_DIR/creframe mode=fl mean=0 lbound=\[{0},{1}\] "
                "ubound=\[{2},{3}\] out={4}".format(lx,ly,ux,uy,qart))
         invoke("$KAPPA_DIR/wcscopy ndf={0} like={1}'(,)' ok=yes".format(qart,junk) )
         invoke("$KAPPA_DIR/creframe mode=fl mean=0 lbound=\[{0},{1}\] "
                "ubound=\[{2},{3}\] out={4}".format(lx,ly,ux,uy,uart))
         invoke("$KAPPA_DIR/wcscopy ndf={0} like={1}'(,)' ok=yes".format(uart,junk) )

   else:
      msg_out( "Using supplied artificial I, Q and U maps...")

#  Ensure the artificial maps have a defined polarimetric reference
#  direction parallel to the pixel Y axis, and ensure they are in units
#  of pW.
   invoke("$KAPPA_DIR/erase object={0}.more.polpack ok=yes".format(iart),annul=True )
   invoke("$KAPPA_DIR/erase object={0}.more.polpack ok=yes".format(qart),annul=True )
   invoke("$KAPPA_DIR/erase object={0}.more.polpack ok=yes".format(uart),annul=True )
   invoke("$POLPACK_DIR/polext in={0} angrot=90".format(iart) )
   invoke("$POLPACK_DIR/polext in={0} angrot=90".format(qart) )
   invoke("$POLPACK_DIR/polext in={0} angrot=90".format(uart) )
   invoke("$KAPPA_DIR/setunits ndf={0} units=pW".format(iart) )
   invoke("$KAPPA_DIR/setunits ndf={0} units=pW".format(qart) )
   invoke("$KAPPA_DIR/setunits ndf={0} units=pW".format(uart) )

#  If required, create an artificial common-mode (i.e. unpolarised emission
#  from the sky) for each sub-scan/grid-point.
   if incom:

#  Process each sub-scan separately as they may have different lengths.
      cfactor = parsys["CFACTOR"].value
      com = NDG.load( "COM" )
      if not com:
         msg_out( "Creating new artificial common-mode signals...")

         conf = os.path.join(NDG.tempdir,"junkconf")
         fd = open(conf,"w")
         fd.write("numiter=1\n")
         fd.write("order=-1\n")
         fd.write("modelorder=(com,gai,ast)\n")
         fd.write("exportndf=(com,gai)\n")
         fd.write("com.gain_box = 2000\n")
         fd.write("downsampscale=0\n")
         fd.close()

         junk = NDG(1)

#  Use makemap to create NDFs holding the COM and GAI models formed from
#  the supplied data.
         invoke("$SMURF_DIR/makemap in={0} out={1} config=^{2}".
                format(incom, junk, conf ) )

#  Identify the COM and GAI NDFs created above in the current directory,
#  and copy them to the temp directory. Then delete them from the current
#  directory.
         ar = starutil.get_fits_header( incom[0], "SUBARRAY", True )
         ut = int(starutil.get_fits_header( incom[0], "UTDATE", True ))
         obs = int(starutil.get_fits_header( incom[0], "OBSNUM", True ))
         comndf = invoke("$KAPPA_DIR/ndfecho {0}{1}_{2:05}_0\*_con_com".format(ar,ut,obs))
         gaindf = invoke("$KAPPA_DIR/ndfecho {0}{1}_{2:05}_0\*_con_gai".format(ar,ut,obs))

         commod = NDG(1)
         invoke("$KAPPA_DIR/ndfcopy in={0} out={1} trim=yes trimbad=yes".format(comndf,commod) )
         os.remove( "{0}.sdf".format(comndf) )

         gaimod = NDG(1)
         invoke("$KAPPA_DIR/ndfcopy in={0} out={1}".format(gaindf,gaimod) )
         os.remove( "{0}.sdf".format(gaindf) )

#  Smooth and fill the COM signal.
         smocom = NDG(1)
         invoke("$KAPPA_DIR/gausmooth in={0} fwhm=3 out={1}".format(commod,smocom))
         fillcom = NDG(1)
         invoke("$KAPPA_DIR/fillbad in={0} out={1}".format(smocom,fillcom) )

#  Find the mean value.
         invoke("$KAPPA_DIR/stats ndf={0} clip=\[3,3,3\] quiet".format(fillcom) )
         mean = int( starutil.get_task_par( "mean", "stats" ))

#  Apply the CFACTOR expansion.
         tmpcom = NDG(1)
         invoke("$KAPPA_DIR/maths exp=\"'pa*(ia-pb)+pb'\" ia={0} pa={1} pb={2} out={3}".
                format(fillcom,cfactor,mean,tmpcom) )

#  Now split the COM signal up into individual files.
         invoke("$KAPPA_DIR/ndftrace ndf={0} quiet".format(tmpcom) )
         lbnd = int( starutil.get_task_par( "lbound(1)", "ndftrace" ))

         com = NDG(ff)
         for icom in range(len( com )):
            invoke("$KAPPA_DIR/ndftrace ndf={0} quiet".format(ff[icom]) )
            ns = int( starutil.get_task_par( "dims(3)", "ndftrace" ))
            ubnd = lbnd + ns - 1
            invoke("$KAPPA_DIR/ndfcopy in={0}\({1}:{2}\) out={3} trim=yes".
                   format(tmpcom,lbnd,ubnd,com[icom]))
            lbnd = ubnd + 1

         com.save( "COM" )

      else:
         msg_out( "Re-using old artificial common-mode signals...")
   else:
      com = "!"

# Generate instrumental normalised Q and U images - 0.07% IP (on average -
# there is a gradient in X). This value, together with the amp4 and phase4
# values used by unmakemap below, produce time-streams that look similar
# to the real thing. The iP is at 15 degrees to the fixed analyser.
   ipqu = NDG.load( "IPQU" )
   if not ipqu:

#  Initialise value to "use no IP".
      ipqu = [ "!", "!" ]

#  See what form of IP to use.
      ipform = parsys["IPFORM"].value

#  First case: user defined IP Model.
      if ipform == "USER":

#  Get the parameters defining the instrumental polarisation
         ipmax = parsys["IPMAX"].value
         ipmin = parsys["IPMIN"].value
         iptheta = parsys["IPTHETA"].value
         msg_out( "Creating new user-defined instrumental polarisation values...")
         ipqu = NDG( 2 )

#  Create a map of the fractional instrumental polarisation across each
#  array. Note, all subarrays are given the same IP pattern.
         ipi = NDG(1)
         invoke("$KAPPA_DIR/maths exp=\"'xa*(pa-pb)/31+pb+xb*0'\" type=_REAL "
                "pa={0} pb={1} lbound=\[0,0\] ubound=\[31,39\] out={2}".
                format(ipmax,ipmin,ipi))

#  Create the corresponding normalised Q and U maps.
         invoke("$KAPPA_DIR/maths exp=\"'ip*cosd(2*pt)'\" ip={0} pt={1} out={2}".
                format(ipi,iptheta,ipqu[0] ))
         invoke("$KAPPA_DIR/maths exp=\"'ip*sind(2*pt)'\" ip={0} pt={1} out={2}".
                format(ipi,iptheta,ipqu[1] ))

         ipqu.save( "IPQU" )

   else:
      msg_out( "Re-using old instrumental polarisation values...")

#  Create GAI values from the supplied template data.
   if addon or not incom:
      gfactor = 0.0
   else:
      gfactor = parsys["GFACTOR"].value

   if gfactor != 0.0:
      gai = NDG.load( "GAI" )
      if not gai:
         msg_out( "Creating new artificial GAI models...")

#  The number of GAI planes in the GAI cube. */
         invoke("$KAPPA_DIR/ndftrace ndf={0} quiet".format(gaimod) )
         ns = int( starutil.get_task_par( "dims(3)", "ndftrace" ))/3
         if ns < len(ff):
            raise UsageError("\n\nInsufficient GAI planes - need {0}, "
                             "have {1}".format(len(ff), ns ) )

#  Smooth and fill the GAI signal.
         smogai = NDG(1)
         invoke("$KAPPA_DIR/gausmooth in={0}'(,,:{2})' fwhm=3 out={1}".
                format(gaimod,smogai,ns))
         fillgai = NDG(1)
         invoke("$KAPPA_DIR/fillbad in={0} out={1}".format(smogai,fillgai) )

#  Apply the GFACTOR expansion.
         tmpgai = NDG(1)
         invoke("$KAPPA_DIR/maths exp=\"'pa*(ia-1)+1'\" ia={0} pa={1} out={2}".
                format(fillgai,cfactor,tmpgai) )

#  Now split the GAI signal up into individual files.
         invoke("$KAPPA_DIR/ndftrace ndf={0} quiet".format(tmpcom) )
         lbnd = int( starutil.get_task_par( "lbound(1)", "ndftrace" ))

         gai = NDG(ff)
         for igai in range(len( gai )):
            invoke("$KAPPA_DIR/ndfcopy in={0}\(,,{1}:{1}\) out={2} trim=yes".
                   format(tmpgai,igai+1,gai[igai]))
            lbnd = ubnd + 1

         gai.save( "GAI" )

      else:
         msg_out( "Re-using old GAI models...")
   else:
      gai = "!"

#  Now create the simulated POL2 time-streams. Try to keep the unmakemap
#  command line as short as possible by omitting defaulted parameters,
#  as it is possible for the command line to be too big for the ADAM
#  parameter system to handle.
   msg_out( "Generating simulated POL2 time-stream data..." )
   if addon:
      artdata = NDG( len(outdata) )
   else:
      artdata = outdata

   parlist = ""


   if pntfile != "!":
      parlist = "{0} pointing={1} ".format(parlist,pntfile)

   if ipqu[0] != "!":
      parlist = "{0} instq={1} ".format(parlist,ipqu[0])

   if ipqu[1] != "!":
      parlist = "{0} instu={1} ".format(parlist,ipqu[1])

   if com != "!":
      parlist = "{0} com={1} ".format(parlist,com)
   elif comval1 != 0.0 or comval2 != 0.0:
      parlist = "{0} comval='[{1},{2}]' ".format(parlist,comval1,comval2)

   if gai != "!":
      parlist = "{0} gai={1} ".format(parlist,gai)

   if amp4 != 0.0:
      parlist = "{0} amp4={1} phase4={2}".format(parlist,amp4,phase4)

   if amp2 != 0.0:
      parlist = "{0} amp2={1} phase2={2}".format(parlist,amp2,phase2)

   if amp16 != 0.0:
      parlist = "{0} amp16={1} phase16={2}".format(parlist,amp16,phase16)

   invoke("$SMURF_DIR/unmakemap in={0} qin={1} uin={2} ref={3} "
          "sigma={4} out={5} interp=sincsinc params=\[0,3\] "
          "ipform={6} {7}".
          format(iart,qart,uart,ff,sigma,artdata,ipform,parlist) )

#  If required, add the artificial time-stream data onto the real
#  time-stream data.
   if addon:
      msg_out( "Adding simulated and real POL2 time-stream data..." )
      invoke("$KAPPA_DIR/add in1={0} in2={1} out={2}".
             format(ff,artdata,outdata))

#  Remove temporary files.
   cleanup()

#  If an StarUtilError of any kind occurred, display the message but hide the
#  python traceback. To see the trace back, uncomment "raise" instead.
except starutil.StarUtilError as err:
#  raise
   print( err )
   cleanup()

# This is to trap control-C etc, so that we can clean up temp files.
except:
   cleanup()
   raise

