#!/bin/sh    
# The next line is executed by /bin/sh, but not Tcl \
TCL_LIBRARY=$GAIA_DIR; \
TCLX_LIBRARY=$GAIA_DIR; \
TK_LIBRARY=$GAIA_DIR; \
TKX_LIBRARY=$GAIA_DIR; \
ITCL_LIBRARY=$GAIA_DIR; \
ITK_LIBRARY=$GAIA_DIR; \
IWIDGETS_LIBRARY=$GAIA_DIR; \
RTD_LIBRARY=$GAIA_DIR; \
TCLADAM_DIR=$GAIA_DIR; \
TIX_LIBRARY=$GAIA_DIR; \
export TCL_LIBRARY; \
export TCLX_LIBRARY; \
export TK_LIBRARY; \
export TKX_LIBRARY; \
export ITCL_LIBRARY; \
export ITK_LIBRARY; \
export IWIDGETS_LIBRARY; \
export RTD_LIBRARY; \
export TCLADAM_DIR; \
export TIX_LIBRARY; \
exec $GAIA_DIR/gaia_wish $0 ${1+"$@"}
#+
#   Name:
#      gaiadisp
#
#   Purpose:
#      Displays an image in a GAIA tool.
#
#   Usage:
#      gaiadisp image [clone_number]
#
#   Description:
#      This command displays a given image in GAIA. The image can 
#      be directed into a specified "clone". If the clone or GAIA 
#      do not exist then they are created. 
#
#      Clones are specified by an integer number less than 1000.
#
#   Notes:
#
#   Authors:
#      Peter W. Draper (PDRAPER):
#
#   History:
#      25-NOV-1996 (PDRAPER):
#         Original version.
#      09-MAR-1998 (PDRAPER):
#         Now uses the remote control interface, rather than send
#         mechanism (less X security complaints).
#-
#.

#  Do not show the main window.
wm withdraw .

#  Load local procedures if needed.
lappend auto_path $env(GAIA_DIR)

#  Check the command-line arguments.
set clone ""
if { $argc >= 1 } { 
   set image [lindex $argv 0]
   if { $argc >= 2 } {
      set clone [lindex $argv 1]
   }
} else {
   puts stderr {Usage: gaiadisp filename [clone_number]}
   exit
}

#  See if the file exists and it so transform into an absolute name
#  (GAIA may not be running in this directory).
if { ! [file readable $image] } { 
   puts stderr "Cannot read image: $image"
   exit 1
} else { 
   if { ! [string match {/*} $image] } {
      #  Name isn't absolute so must be relative.
      set image [pwd]/$image
   }
}

#  Open a socket to a GAIA application and return the file descriptor
#  for remote commands. If a GAIA isn't found then start one up.
proc connect_to_gaia {} {
   global env

   #  Get the hostname and port info from the file ~/.rtd-remote,
   #  which is created by rtdimage when the remote subcommand is
   #  used.
   set tries 0
   while { 1 } {
      set needed 0

      #  Open the file containing the GAIA process information and read it.
      if {[catch {set fd [open $env(HOME)/.rtd-remote]} msg]} {
         set needed 1
      } else {
         lassign [read $fd] pid host port
         close $fd
      }

      #  See if the process is listening to this socket.
      if { ! $needed } {
         if {[catch {socket $host $port} msg]} {
            set needed 1
         } else {
            puts stderr "Connected to GAIA..."
            fconfigure $msg -buffering line
            return $msg
         }
      }

      #  If the process doesn't exist and we've not been around the
      #  loop already, then start a new GAIA.
      if { $needed && $tries == 0 } {
         puts stderr "Failed to connect to GAIA, starting new instance..."
         exec $env(GAIA_DIR)/gaia.sh &
         # exec $env(GAIA_DIR)/tgaia &
      }

      #  Now either wait and try again or give up if waited too long.
      if { $needed && $tries < 500 } {
         #  Wait for a while and then try again.
         incr tries
         after 1000
      } elseif { $needed } {
         puts stderr "Sorry timed out: failed to display image in GAIA"
         exit 1
      }
   }
}

#  Send the command to GAIA and return the results or generate an error.
proc send_to_gaia {args} {
    global gaia_fd
    puts $gaia_fd "$args"
    lassign [gets $gaia_fd] status length
    set result {}
    if {$length > 0} {
	set result [read $gaia_fd $length]
    }
    if {$status != 0} {
	error $result
    }
    return $result
}

#  Open up connection to GAIA.
set gaia_fd [connect_to_gaia]


#  Send the command and output any result.
if { $clone != "" } { 
    eval send_to_gaia clone $clone $image
    puts stderr "Displayed image: $image in clone: $clone."
} else {

    #  Command needs to performed by Skycat or derived
    #  object. We just talk to the first window on the list.
    set cmd "winfo parent \[SkyCat::get_skycat_images\]"
    set images [send_to_gaia remotetcl $cmd]
    set ctrlwidget [lindex $images 0]
    set cmd "$ctrlwidget open $image"
    set ret [send_to_gaia remotetcl $cmd]
    if { $ret == "" } { 
       puts stderr "Displayed image: $image."
    } else {
       puts stderr "Failed to display image: ($ret)"
    }
}
close $gaia_fd
exit
