#+
#  Name:
#     StarArdRotBox

#  Type of Module:
#     [incr Tcl] class

#  Purpose:
#     Defines a class of object for controlling an ARD rotbox drawn
#     using a StarCanvasDraw object.

#  Description:
#     This class provides the basic functionality for controlling an
#     ARD rectangle region. It provides the basic draw facilities and
#     returns an ARD description of the region.

#  Invocations:
#
#        StarArdRotBox object_name [configuration options]
#
#     This creates an instance of a StarArdRotBox object. The return is
#     the name of the object.
#
#        object_name configure -configuration_options value
#
#     Applies any of the configuration options (after the instance has
#     been created).
#
#        object_name method arguments
#
#     Performs the given method on this object.

#  Configuration options:
#     See public variable defintions.

#  Methods:
#     See method definitions.

#  Inheritance:
#     This class inherits StarArdPrim.

#  Copyright:
#     Copyright (C) 1997 Central Laboratory of the Research Councils

#  Authors:
#     PDRAPER: Peter Draper (STARLINK - Durham University)
#     {enter_new_authors_here}

#  History:
#     8-MAY-1996 (PDRAPER):
#        Original version.
#     5-JUL-1996 (PDRAPER):
#        Converted to itcl2.0.
#     {enter_further_changes_here}

#-

#.

class gaia::StarArdRotBox {

   #  Inheritances:
   #  -------------

   inherit StarArdPrim

   #  Constructor:
   #  ------------
   constructor {args} {

      #  Set the type of canvas object.
      configure -mode rotbox
      eval configure $args
   }

   #  Destructor:
   #  -----------
   destructor  {
   }

   #  Methods:
   #  --------

   #  Return the ARD description of the object.
   method getard {{do_update 1}} {

      #  Make sure that the coords are up to date, if allowed.
      if { $do_update} { update $canvas_id_ resize }
      lassign $coords xs ys
      set smaj [$canvas itemcget $canvas_id_ -semimajor]
      set smin [$canvas itemcget $canvas_id_ -semiminor]
      set ang [$canvas itemcget $canvas_id_ -angle]
      lassign [image_coord $xs $ys] x y
      set major [image_dist [expr $smaj*2.0]]
      set minor [image_dist [expr $smin*2.0]]
      set angle [image_angle $ang]
      return "ROTBOX($x,$y,$major,$minor,$angle)"
   }

   #  Set the properties of the object to those of an ARD description
   #  of an object of this type.
   method setard {desc} {
      if { $desc != "" } {
         set failed 1
         if { [check_description rotbox $desc] } {
            if { [llength $qualifiers_] == 5 } {
               lassign $qualifiers_ x y major minor angle
               lassign [canvas_coord $x $y] xs ys
               set maj [canvas_dist $major]
               set min [canvas_dist $minor]
               set ang [canvas_angle $angle $x $y]
               configure -coords "$xs $ys"
               configure -major $maj
               configure -minor $min
               configure -angle $ang
               set failed 0
            }
         }
         if { $failed } {
            error "Failed to interpret \"$desc\" as an ARD rotbox"
         }
      }
   }

   #  Create a new rotbox using an ARD description.
   method createard {desc {cmd {}}} {
      setard "$desc"
      create_no_resize [code $this set_size_ $cmd] $coords
   }

   #  Set the size after a static creation command and evaluate the
   #  creation command.
   method set_size_ {args} {
      $canvas itemconfigure $canvas_id_ \
         -semimajor [expr $major/2.0] -semiminor [expr $minor/2.0] -angle $angle
      if { [lindex $args 0] != {} } {
         eval $args
      }
   }


   #  Create a top-level window that describes the current object and
   #  allows its values to be changed.
   method show_properties {{name ""}} {
      if { $name == {} } {
         set name ".rotbox$canvas_id_"
      }
      if { ! [create_properties_window $name] } {

         #  Now add the buttons for the description.
         set Xcentre_ [LabelEntry $Frame_.xcentre \
                          -text {X centre:} \
                          -labelwidth $labelwidth_ \
                          -command [code $this configure -x]]
         set Ycentre_ [LabelEntry $Frame_.ycentre \
                          -text {Y centre:} \
                          -labelwidth $labelwidth_ \
                          -command [code $this configure -y]]
         set Major_ [LabelEntry $Frame_.major \
                         -text {Major axis:}\
                          -labelwidth $labelwidth_ \
                        -command [code $this configure -major]]
         set Minor_ [LabelEntry $Frame_.minor \
                         -text {Minor axis:}\
                          -labelwidth $labelwidth_ \
                        -command [code $this configure -minor]]
         set Angle_ [LabelEntry $Frame_.angle \
                         -text {Position angle:}\
                          -labelwidth $labelwidth_ \
                        -command [code $this configure -angle]]
         pack $Xcentre_ $Ycentre_ $Major_ $Minor_ $Angle_ -side top -fill x
      }

      #  Update the information to be current.
      update_properties
   }

   #  Update all properties.
   method update_properties {} {

      #  Make sure record of canvas item values is up todate.
      update $canvas_id_ resize
      lassign $coords xs ys
      set smaj [$canvas itemcget $canvas_id_ -semimajor]
      set smin [$canvas itemcget $canvas_id_ -semiminor]
      set ang [$canvas itemcget $canvas_id_ -angle]
      lassign [image_coord $xs $ys] x y
      set major [image_dist [expr $smaj*2.0]]
      set minor [image_dist [expr $smin*2.0]]
      set angle [image_angle $ang]

      #  Update the properties box if it exists.
      if { [winfo exists $Properties_] } {
         $Xcentre_ configure -value $x
         $Ycentre_ configure -value $y
         $Major_ configure -value $major
         $Minor_ configure -value $minor
         $Angle_ configure -value $angle
      }
   }

   #  Procedures: (access common values)
   #  -----------

   #  Configuration options: (public variables)
   #  ----------------------
   #  X position in image coordinates.
   public variable x {0} {
      if { [winfo exists $Xcentre_] } {
         $Xcentre_ configure -value $x
         lassign [canvas_coord $x $y] xs ys
         set coords "$xs $y"
         redraw
      }
   }

   #  Y position in image coordinates.
   public variable y {0} {
      if { [winfo exists $Ycentre_] } {
         $Ycentre_ configure -value $y
         lassign [canvas_coord $x $y] xs ys
         set coords "$x $ys"
         redraw
      }
   }

   #  Major axis in image pixels.
   public variable major {10} {
      if { [winfo exists $Major_] } {
         $Major_ configure -value $major
         set smaj [canvas_dist [expr $major/2.0]]
         $canvas itemconfigure $canvas_id_ -semimajor $smaj
      }
   }

   #  Minor axis in image pixels.
   public variable minor {5} {
      if { [winfo exists $Minor_] } {
         $Minor_ configure -value $minor
         set smin [canvas_dist [expr $minor/2.0]]
         $canvas itemconfigure $canvas_id_ -semiminor $smin
      }
   }

   #  Position angle.
   public variable angle {0} {
      if { [winfo exists $Angle_] } {
         $Angle_ configure -value $angle
         set ang [canvas_angle $angle $x $y]
         $canvas itemconfigure $canvas_id_ -angle $ang
      }
   }

   #  Protected variables: (available to instance)
   #  --------------------

   #  Properties widgets.
   protected variable Xcentre_ {}
   protected variable Ycentre_ {}
   protected variable Major_ {}
   protected variable Minor_ {}
   protected variable Angle_ {}

   #  Common variables: (shared by all instances)
   #  -----------------

#  End of class definition.
}
