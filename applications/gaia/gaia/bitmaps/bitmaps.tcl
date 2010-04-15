#!../bin/gaia_wish
#
# E.S.O. - VLT project/ ESO Archive
#
# "$Id$"
#
#  script to generate C code declaring X bitmaps so that the (binary)
#  application doesn't have to be delivered with the bitmap files.
#
# who             when       what
# --------------  ---------  ----------------------------------------
# Allan Brighton  21 Nov 95  Created
# Peter W. Draper 17 May 99  Modified for use in GAIA

puts {
/*
 * E.S.O. - VLT project / ESO Archive
 * "@(#) $Id$"
 *
 * Tk Bitmap/Pixmap definitions
 *
 * This file was generated by ../bitmaps/bitmaps.tcl  - DO NO EDIT
 */

#include <tcl.h>
#include <tk.h>

}
puts "void defineGaiaBitmaps(Tcl_Interp *interp) {"

foreach file [glob -nocomplain *.xbm] {
    set name [file rootname $file]
    puts "    #include \"$file\""
    puts "    Tk_DefineBitmap(interp, Tk_GetUid(\"$name\"), (char*)${name}_bits, ${name}_width, ${name}_height);\n"
}

#foreach file [glob -nocomplain *.xpm] {
#    set name [file rootname $file]
#    regsub -all -- - $name _ name
#    puts "    #include \"$file\""
#    puts "    Tix_DefinePixmap(interp, Tk_GetUid(\"$name\"), ${name}_xpm);\n"
#}

puts "}"

exit 0
