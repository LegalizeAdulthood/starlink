/* Name:
      stcschan-demo4.c

   Purpose:
      A demonstration of the facilities provided by the AST library
      for reading STC metadata encoded using the STC-S linear string
      format.

   Description:
      This program reads two STC-S descriptions from two disk files,
      and tests them for overlap. The two descriptions need not refer
      to the same coordinate system. Built-in conversions within AST
      will be used to align them if the coordinate systems differ.

   Usage:
      % stcschan-demo4 <stcs-file1> <stcs-file2>

      <stcs-file1>: The path to the disk file containing the first STC-S
      description.

      <stcs-file2>: The path to the disk file containing the second STC-S
      description.

   Example:
      % stcschan-demo4 stcs-ex1.txt stcs-ex2.txt

   To compile and link:
      Assuming your starlink distribution is in "/star":

      % gcc -o stcschan-demo4 stcschan-demo4.c -L/star/lib \
            -I/star/include `ast_link`
*/

/* Include system headers. */
#include <stdio.h>
#include <string.h>

/* Include the AST library header. */
#include "ast.h"

/* Maximum number of axes in an STC-S AstroCoordSystem. */
#define MAX_AXES 5

/* Maximum allowed length for a single line of text form the disk file. */
#define MAX_LINE_LEN 500

/* Prototypes: */
const char *source( void );
AstRegion *ReadStcs( AstStcsChan *chan, const char *file, int *status );

int main( int argc, char **argv ){

/* Local variables: */
   AstRegion *region1;
   AstRegion *region2;
   AstStcsChan *channel;
   int status;

/* Initialised the returned system status to indicate success. */
   status = 0;

/* Check two files were specified on the command line. */
   if( argc < 3 ) {
      printf( "Usage: stcschan-demo4 <stcs-file1> <stcs-file2> \n" );
      status = 1;
   }

/* Start an AST object context. This means we do not need to annull
   each AST Object individually. Instead, all Objects created within
   this context will be annulled automatically by the corresponding
   invocation of astEnd. */
   astBegin;

/* Create an StcsChan. This is the object that converts between external
   STC-S descriptions and the corresponding AST Objects. Tell it to use the
   "source" function for obtaining lines of text from the disk file. Also
   tell it to store all warnings generated by the conversion for later
   use. Other attributes of the StcsChan class retain their default
   values. */
   channel = astStcsChan( source, NULL, "ReportLevel=3" );

/* Attempt to read the STC-S description from the first file, and produce
   a corresponding AST Region object. The conversion is performed by the
   StcsChan created above. */
   region1 = ReadStcs( channel, argv[ 1 ], &status );

/* Now attempt to read the STC-S description from the second file,
   producing a corresponding AST Region object. We re-use the StcsChan
   created above. */
   region2 = ReadStcs( channel, argv[ 2 ], &status );

/* If we have two Regions, test them for overlap and tell the user the
   result of the test. */
   if( region1 && region2 ) {
      switch( astOverlap( region1, region2 ) ) {

         case 1:
            printf( "\n   There is no overlap between the two Regions.\n\n");
            break;

         case 2:
            printf( "\n   The first Region is completely inside the second Region.\n\n");
            break;

         case 3:
            printf( "\n   The second Region is completely inside the first Region.\n\n");
            break;

         case 4:
            printf( "\n   There is partial overlap between the two Regions.\n\n");
            break;

         case 5:
            printf( "\n   The Regions are identical to within their uncertainties.\n\n");
            break;

         case 6:
            printf( "\n   The second Region is the exact negation of the first "
                    "Region to within their uncertainties. \n\n");
            break;

         default:
            if( astOK ) printf( "\n   Unexpected value returned by astOverlap\n\n" );
      }
   }

/* End the AST Object context. All Objects created since the
   corresponding invocation of astbegin will be annulled automatically. */
   astEnd;

/* If an error occurred in the AST library, set the retiurns system
   status non-zero. */
   if( !astOK ) status = 1;
   return status;
}







/* This is a function that reads a line of text from the disk file and
   returns it to the AST library. It is called from within the astRead
   function. */
const char *source( void ){
   static char buffer[ MAX_LINE_LEN + 2 ];
   FILE *fd = astChannelData;
   return fgets( buffer, MAX_LINE_LEN + 2, fd );
}





/* -------------------------------------------------------------------
 * This function reads an STC-S description from a given text file,
 * and attempts to convert them into an AST Region. If successful, a
 * pointer to the Region is returned. A NULL pointer is returned if
 * anything goes wrong.
*/

AstRegion *ReadStcs( AstStcsChan *chan, const char *file, int *status ){
   AstKeyMap *warnings;
   AstObject *object;
   AstRegion *result;
   FILE *fd;
   char key[ 15 ];
   const char *message;
   int iwarn;

/* Initialise the returned pointer to indicate that no Region has yet
   been read. */
   result = NULL;

/* If an error has already occurred, return without action. */
   if( *status != 0 ) return result;

/* Attempt to open the STC-S file */
   fd = fopen( file, "r" );
   if( !fd ) {
      printf("Failed to open STC-S descrption file '%s'.\n", file );

/* If successful... */
   } else {

/* Associate the descriptor for the input disk file with the StcsChan.
   This makes it available to the "source" function. Since this
   application is single threaded, we could instead have made "fd" a
   global variable, but the ChannelData facility is used here to illustrate
   how to pass data to a source or sink function safely in a multi-threaded
   application. */
      astPutChannelData( chan, fd );

/* The default behaviour of the astRead function when used on an StcsChan is
   to read and return the AstroCoordArea as an AST Region. This behaviour
   can be changed by assigning appropriate values to the StcsChan attributes
   "StcsArea", "StcsCoords" and "StcsProps". Options exist to return the
   AstroCoords as an AST PointList, and/or to return the individual
   property values read from the STC-S text in the form of an AST KeyMap
   (a sort of hashmap). For now, just take the default action of reading the
   AstroCoordsArea. */
      object = astRead( chan );

/* The astRead function is a generic function and so returns a generic
   AstObject pointer. Check an Object was created successfully. */
      if( !object ) {
         printf( "Failed to read an AST Object from STC-S description "
                 "file '%s'.\n", file );

/* Now check that the object read is actually an AST Region, rather than
   some other class of AST Object. */
      } else if( !astIsARegion( object ) ) {
         printf( "Expected a Region but read a %s from STC-S description "
                 "file '%s'.\n", astGetC( object, "Class" ), file );

/* If the Object is a Region, return the Region pointer. */
      } else {
         result = (AstRegion *) object;
      }

/* Close the file. */
      fclose( fd );

/* If the StcsChan recorded any warnings that were generated whilst
   converting the STC-S description into a corresponding AST Object,
   we now display them. First test the ReportLevel attribute value to see
   if warnings were recored. */
      if( astGetI( chan, "ReportLevel" ) > 0 ) {

/* Any warnings recorded during the conversion performed by astRead above
   are returned by the astWarnings method, in the form of an AST "KeyMap"
   (a type of hash map ). */
         warnings = astWarnings( chan );

/* If any warnings were generated, and if no other error has occurred so
   far, display the warnings. */
         if( warnings && !status && astOK ) {
            printf( "\nThe following warnings were issued reading file "
                    "'%s':\n", file );

/* The warnings are stored in an AST KeyMap (a sort of hashmap). Each
   warning message is associated with a key of the form "Warning_1",
   "Warning_2", etc. Loop round successive keys, obtaining a value for
   each key from the warnings KeyMap, and displaying it. */
            iwarn = 1;
            while( astOK ) {
               sprintf( key, "Warning_%d", iwarn++ );
               if( astMapGet0C( warnings, key, &message ) ) {
                  printf( "\n- %s\n", message );
               } else {
                  break;
               }
            }
         }
      }
   }

   return result;
}


