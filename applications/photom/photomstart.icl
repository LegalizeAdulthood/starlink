{
{             PHOTOM UNIX ICL startup file
{
{  Define commands to run the PHOTOM software
{
define photom        $PHOTOM_DIR/photom_mon
defhelp photom       $PHOTOM_HELP
define photopt       $PHOTOM_DIR/photom_mon
defhelp photopt      $PHOTOM_HELP
define photgrey      $PHOTOM_DIR/photom_mon
defhelp photgrey     $PHOTOM_HELP
define autophotom    $PHOTOM_DIR/photom_mon
defhelp autophotom   $PHOTOM_HELP

{
{ Print welcome message
{
print " "
print "   PHOTOM commands are now available - (Version PKG_VERS)"
print " "
print "   For help use the command 'help photom'"
print " "
