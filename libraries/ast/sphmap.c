/*
*class++
*  Name:
*     SphMap

*  Purpose:
*     Map 3-d Cartesian to 2-d spherical coordinates

*  Constructor Function:
c     astSphMap
f     AST_SPHMAP

*  Description:
*     A SphMap is a Mapping which transforms points from a
*     3-dimensional Cartesian coordinate system into a 2-dimensional
*     spherical coordinate system (longitude and latitude on a unit
*     sphere centred at the origin). It works by regarding the input
*     coordinates as position vectors and finding their intersection
*     with the sphere surface. The inverse transformation always
*     produces points which are a unit distance from the origin
*     (i.e. unit vectors).

*  Inheritance:
*     The SphMap class inherits from the Mapping class.

*  Attributes:
*     In addition to those attributes common to all Mappings, every
*     SphMap also has the following attributes:
*
*     - UnitRadius: SphMap input vectors lie on a unit sphere?

*  Functions:
c     The SphMap class does not define any new functions beyond those
f     The SphMap class does not define any new routines beyond those
*     which are applicable to all Mappings.

*  Copyright:
*     <COPYRIGHT_STATEMENT>

*  Authors:
*     DSB: David Berry (Starlink)
*     RFWS: R.F. Warren-Smith (Starlink)

*  History:
*     24-OCT-1996 (DSB):
*        Original version.
*     5-MAR-1997 (RFWS):
*        Tidied public prologues.
*     24-MAR-1998 (RFWS):
*        Override the astMapMerge method.
*     4-SEP-1998 (DSB):
*        Added UnitRadius attribute.
*class--
*/

/* Module Macros. */
/* ============== */
/* Set the name of the class we are implementing. This indicates to
   the header files that define class interfaces that they should make
   "protected" symbols available. */
#define astCLASS SphMap

/* Include files. */
/* ============== */
/* Interface definitions. */
/* ---------------------- */
#include "error.h"               /* Error reporting facilities */
#include "memory.h"              /* Memory management facilities */
#include "object.h"              /* Base Object class */
#include "pointset.h"            /* Sets of points/coordinates */
#include "mapping.h"             /* Coordinate mappings (parent class) */
#include "channel.h"             /* I/O channels */
#include "unitmap.h"             /* Unit (identity) Mappings */
#include "sphmap.h"              /* Interface definition for this class */
#include "slalib.h"              /* SLA transformations */

/* Error code definitions. */
/* ----------------------- */
#include "ast_err.h"             /* AST error codes */

/* C header files. */
/* --------------- */
#include <float.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

/* Module Variables. */
/* ================= */
/* Define the class virtual function table and its initialisation flag
   as static variables. */
static AstSphMapVtab class_vtab; /* Virtual function table */
static int class_init = 0;       /* Virtual function table initialised? */

/* Pointers to parent class methods which are extended by this class. */
static AstPointSet *(* parent_transform)( AstMapping *, AstPointSet *, int, AstPointSet * );
static const char *(* parent_getattrib)( AstObject *, const char * );
static int (* parent_testattrib)( AstObject *, const char * );
static void (* parent_clearattrib)( AstObject *, const char * );
static void (* parent_setattrib)( AstObject *, const char * );

/* External Interface Function Prototypes. */
/* ======================================= */
/* The following functions have public prototypes only (i.e. no
   protected prototypes), so we must provide local prototypes for use
   within this module. */
AstSphMap *astSphMapId_( const char *, ... );

/* Prototypes for Private Member Functions. */
/* ======================================== */
static int GetUnitRadius( AstSphMap * );
static int TestUnitRadius( AstSphMap * );
static void ClearUnitRadius( AstSphMap * );
static void SetUnitRadius( AstSphMap *, int );

static AstPointSet *Transform( AstMapping *, AstPointSet *, int, AstPointSet * );
static const char *GetAttrib( AstObject *, const char * );
static int MapMerge( AstMapping *, int, int, int *, AstMapping ***, int ** );
static int TestAttrib( AstObject *, const char * );
static void ClearAttrib( AstObject *, const char * );
static void Copy( const AstObject *, AstObject * );
static void Delete( AstObject * );
static void Dump( AstObject *, AstChannel * );
static void InitVtab( AstSphMapVtab * );
static void SetAttrib( AstObject *, const char * );

/* Member functions. */
/* ================= */
static void ClearAttrib( AstObject *this_object, const char *attrib ) {
/*
*  Name:
*     ClearAttrib

*  Purpose:
*     Clear an attribute value for a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     void ClearAttrib( AstObject *this, const char *attrib )

*  Class Membership:
*     SphMap member function (over-rides the astClearAttrib protected
*     method inherited from the Mapping class).

*  Description:
*     This function clears the value of a specified attribute for a
*     SphMap, so that the default value will subsequently be used.

*  Parameters:
*     this
*        Pointer to the SphMap.
*     attrib
*        Pointer to a null-terminated string specifying the attribute
*        name.  This should be in lower case with no surrounding white
*        space.
*/

/* Local Variables: */
   AstSphMap *this;             /* Pointer to the SphMap structure */

/* Check the global error status. */
   if ( !astOK ) return;

/* Obtain a pointer to the SphMap structure. */
   this = (AstSphMap *) this_object;

/* UnitRadius */
/* ---------- */
   if ( !strcmp( attrib, "unitradius" ) ) {
      astClearUnitRadius( this );

/* If the attribute is still not recognised, pass it on to the parent
   method for further interpretation. */
   } else {
      (*parent_clearattrib)( this_object, attrib );
   }
}

static const char *GetAttrib( AstObject *this_object, const char *attrib ) {
/*
*  Name:
*     GetAttrib

*  Purpose:
*     Get the value of a specified attribute for a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     const char *GetAttrib( AstObject *this, const char *attrib )

*  Class Membership:
*     SphMap member function (over-rides the protected astGetAttrib
*     method inherited from the Mapping class).

*  Description:
*     This function returns a pointer to the value of a specified
*     attribute for a SphMap, formatted as a character string.

*  Parameters:
*     this
*        Pointer to the SphMap.
*     attrib
*        Pointer to a null-terminated string containing the name of
*        the attribute whose value is required. This name should be in
*        lower case, with all white space removed.

*  Returned Value:
*     - Pointer to a null-terminated string containing the attribute
*     value.

*  Notes:
*     - The returned string pointer may point at memory allocated
*     within the SphMap, or at static memory. The contents of the
*     string may be over-written or the pointer may become invalid
*     following a further invocation of the same function or any
*     modification of the SphMap. A copy of the string should
*     therefore be made if necessary.
*     - A NULL pointer will be returned if this function is invoked
*     with the global error status set, or if it should fail for any
*     reason.
*/

/* Local Constants: */
#define BUFF_LEN 10              /* Max. characters in result buffer */

/* Local Variables: */
   AstSphMap *this;              /* Pointer to the SphMap structure */
   const char *result;           /* Pointer value to return */
   int ival;                     /* Int attribute value */
   static char buff[ BUFF_LEN + 1 ]; /* Buffer for string result */

/* Initialise. */
   result = NULL;

/* Check the global error status. */   
   if ( !astOK ) return result;

/* Obtain a pointer to the SphMap structure. */
   this = (AstSphMap *) this_object;

/* UnitRadius. */
/* ------- */
   if ( !strcmp( attrib, "unitradius" ) ) {
      ival = astGetUnitRadius( this );
      if ( astOK ) {
         (void) sprintf( buff, "%d", ival );
         result = buff;
      }

/* If the attribute name was not recognised, pass it on to the parent
   method for further interpretation. */
   } else {
      result = (*parent_getattrib)( this_object, attrib );
   }
   
/* Return the result. */
   return result;

/* Undefine macros local to this function. */
#undef BUFF_LEN
}

static void InitVtab( AstSphMapVtab *vtab ) {
/*
*  Name:
*     InitVtab

*  Purpose:
*     Initialise a virtual function table for a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     void InitVtab( AstSphMapVtab *vtab )

*  Class Membership:
*     SphMap member function.

*  Description:
*     This function initialises the component of a virtual function
*     table which is used by the SphMap class.

*  Parameters:
*     vtab
*        Pointer to the virtual function table. The components used by
*        all ancestral classes should already have been initialised.
*/

/* Local Variables: */
   AstObjectVtab *object;        /* Pointer to Object component of Vtab */
   AstMappingVtab *mapping;      /* Pointer to Mapping component of Vtab */

/* Check the local error status. */
   if ( !astOK ) return;

/* Store a unique "magic" value in the virtual function table. This
   will be used (by astIsASphMap) to determine if an object belongs
   to this class.  We can conveniently use the address of the (static)
   class_init variable to generate this unique value. */
   vtab->check = &class_init;

/* Initialise member function pointers. */
/* ------------------------------------ */
/* Store pointers to the member functions (implemented here) that provide
   virtual methods for this class. */
   vtab->ClearUnitRadius = ClearUnitRadius;
   vtab->SetUnitRadius = SetUnitRadius;
   vtab->GetUnitRadius = GetUnitRadius;
   vtab->TestUnitRadius = TestUnitRadius;

/* Save the inherited pointers to methods that will be extended, and
   replace them with pointers to the new member functions. */
   object = (AstObjectVtab *) vtab;
   mapping = (AstMappingVtab *) vtab;

   parent_clearattrib = object->ClearAttrib;
   object->ClearAttrib = ClearAttrib;
   parent_getattrib = object->GetAttrib;
   object->GetAttrib = GetAttrib;
   parent_setattrib = object->SetAttrib;
   object->SetAttrib = SetAttrib;
   parent_testattrib = object->TestAttrib;
   object->TestAttrib = TestAttrib;

   parent_transform = mapping->Transform;
   mapping->Transform = Transform;

/* Store replacement pointers for methods which will be over-ridden by
   new member functions implemented here. */
   mapping->MapMerge = MapMerge;

/* Declare the class dump, copy and delete functions.*/
   astSetDump( vtab, Dump, "SphMap", "Cartesian to Spherical mapping" );
   astSetCopy( (AstObjectVtab *) vtab, Copy );
   astSetDelete( (AstObjectVtab *) vtab, Delete );

}

static int MapMerge( AstMapping *this, int where, int series, int *nmap,
                     AstMapping ***map_list, int **invert_list ) {
/*
*  Name:
*     MapMerge

*  Purpose:
*     Simplify a sequence of Mappings containing a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     int MapMerge( AstMapping *this, int where, int series, int *nmap,
*                   AstMapping ***map_list, int **invert_list )

*  Class Membership:
*     SphMap method (over-rides the protected astMapMerge method
*     inherited from the Mapping class).

*  Description:
*     This function attempts to simplify a sequence of Mappings by
*     merging a nominated SphMap in the sequence with its neighbours,
*     so as to shorten the sequence if possible.
*
*     In many cases, simplification will not be possible and the
*     function will return -1 to indicate this, without further
*     action.
*
*     In most cases of interest, however, this function will either
*     attempt to replace the nominated SphMap with one which it
*     considers simpler, or to merge it with the Mappings which
*     immediately precede it or follow it in the sequence (both will
*     normally be considered). This is sufficient to ensure the
*     eventual simplification of most Mapping sequences by repeated
*     application of this function.
*
*     In some cases, the function may attempt more elaborate
*     simplification, involving any number of other Mappings in the
*     sequence. It is not restricted in the type or scope of
*     simplification it may perform, but will normally only attempt
*     elaborate simplification in cases where a more straightforward
*     approach is not adequate.

*  Parameters:
*     this
*        Pointer to the nominated SphMap which is to be merged with
*        its neighbours. This should be a cloned copy of the SphMap
*        pointer contained in the array element "(*map_list)[where]"
*        (see below). This pointer will not be annulled, and the
*        SphMap it identifies will not be modified by this function.
*     where
*        Index in the "*map_list" array (below) at which the pointer
*        to the nominated SphMap resides.
*     series
*        A non-zero value indicates that the sequence of Mappings to
*        be simplified will be applied in series (i.e. one after the
*        other), whereas a zero value indicates that they will be
*        applied in parallel (i.e. on successive sub-sets of the
*        input/output coordinates).
*     nmap
*        Address of an int which counts the number of Mappings in the
*        sequence. On entry this should be set to the initial number
*        of Mappings. On exit it will be updated to record the number
*        of Mappings remaining after simplification.
*     map_list
*        Address of a pointer to a dynamically allocated array of
*        Mapping pointers (produced, for example, by the astMapList
*        method) which identifies the sequence of Mappings. On entry,
*        the initial sequence of Mappings to be simplified should be
*        supplied.
*
*        On exit, the contents of this array will be modified to
*        reflect any simplification carried out. Any form of
*        simplification may be performed. This may involve any of: (a)
*        removing Mappings by annulling any of the pointers supplied,
*        (b) replacing them with pointers to new Mappings, (c)
*        inserting additional Mappings and (d) changing their order.
*
*        The intention is to reduce the number of Mappings in the
*        sequence, if possible, and any reduction will be reflected in
*        the value of "*nmap" returned. However, simplifications which
*        do not reduce the length of the sequence (but improve its
*        execution time, for example) may also be performed, and the
*        sequence might conceivably increase in length (but normally
*        only in order to split up a Mapping into pieces that can be
*        more easily merged with their neighbours on subsequent
*        invocations of this function).
*
*        If Mappings are removed from the sequence, any gaps that
*        remain will be closed up, by moving subsequent Mapping
*        pointers along in the array, so that vacated elements occur
*        at the end. If the sequence increases in length, the array
*        will be extended (and its pointer updated) if necessary to
*        accommodate any new elements.
*
*        Note that any (or all) of the Mapping pointers supplied in
*        this array may be annulled by this function, but the Mappings
*        to which they refer are not modified in any way (although
*        they may, of course, be deleted if the annulled pointer is
*        the final one).
*     invert_list
*        Address of a pointer to a dynamically allocated array which,
*        on entry, should contain values to be assigned to the Invert
*        attributes of the Mappings identified in the "*map_list"
*        array before they are applied (this array might have been
*        produced, for example, by the astMapList method). These
*        values will be used by this function instead of the actual
*        Invert attributes of the Mappings supplied, which are
*        ignored.
*
*        On exit, the contents of this array will be updated to
*        correspond with the possibly modified contents of the
*        "*map_list" array.  If the Mapping sequence increases in
*        length, the "*invert_list" array will be extended (and its
*        pointer updated) if necessary to accommodate any new
*        elements.

*  Returned Value:
*     If simplification was possible, the function returns the index
*     in the "map_list" array of the first element which was
*     modified. Otherwise, it returns -1 (and makes no changes to the
*     arrays supplied).

*  Notes:
*     - A value of -1 will be returned if this function is invoked
*     with the global error status set, or if it should fail for any
*     reason.
*/

/* Local Variables: */
   AstMapping *new;              /* Pointer to replacement Mapping */
   const char *class;            /* Pointer to Mapping class string */
   int imap1;                    /* Index of first SphMap */
   int imap2;                    /* Index of second SphMap */
   int imap;                     /* Loop counter for Mappings */
   int result;                   /* Result value to return */
   int simpler;                  /* Mappings simplified? */

/* Initialise the returned result. */
   result = -1;

/* Check the global error status. */
   if ( !astOK ) return result;

/* Further initialisation. */
   new = NULL;
   simpler = 0;

/* We will only handle the case of SphMaps in series and will consider
   merging the nominated SphMap with the Mapping which follows
   it. Check that there is such a Mapping. */
   if ( series && ( ( where + 1 ) < *nmap ) ) {

/* Obtain the indices of the two potential SphMaps to be merged. */
      imap1 = where;
      imap2 = where + 1;

/* Obtain the Class string of the second Mapping and determine if it
   is a SphMap. */
      class = astGetClass( ( *map_list )[ imap2 ] );
      if ( astOK && !strcmp( class, "SphMap" ) ) {

/* Check if the first SphMap is applied in the inverse direction and
   the second in the forward direction. This combination can always 
   be simplified. */
         if( ( *invert_list )[ imap1 ] && !( *invert_list )[ imap2 ] ) {
            simpler = 1;

/* If the first SphMap is applied in the forward direction and the second in 
   the inverse direction, the combination can only be simplified if the 
   input vectors to the first SphMap all have unit length (as indicated by 
   the UnitRadius attribute). */
         } else if( !( *invert_list )[ imap1 ] && ( *invert_list )[ imap2 ] ) {
            simpler = astGetUnitRadius( ( *map_list )[ imap1 ] );
         }
      }

/* If the two SphMaps can be simplified, create a UnitMap to replace
   them. */
      if ( simpler ) {
         new = (AstMapping *) astUnitMap( 2, "" );

/* Annul the pointers to the SphMaps. */
         if ( astOK ) {
            ( *map_list )[ imap1 ] = astAnnul( ( *map_list )[ imap1 ] );
            ( *map_list )[ imap2 ] = astAnnul( ( *map_list )[ imap2 ] );

/* Insert the pointer to the replacement Mapping and initialise its
   invert flag. */
            ( *map_list )[ imap1 ] = new;
            ( *invert_list )[ imap1 ] = 0;

/* Loop to close the resulting gap by moving subsequent elements down
   in the arrays. */
            for ( imap = imap2 + 1; imap < *nmap; imap++ ) {
               ( *map_list )[ imap - 1 ] = ( *map_list )[ imap ];
               ( *invert_list )[ imap - 1 ] = ( *invert_list )[ imap ];
            }

/* Clear the vacated elements at the end. */
            ( *map_list )[ *nmap - 1 ] = NULL;
            ( *invert_list )[ *nmap - 1 ] = 0;

/* Decrement the Mapping count and return the index of the first
   modified element. */
            ( *nmap )--;
            result = imap1;
         }
      }
   }

/* If an error occurred, clear the returned result. */
   if ( !astOK ) result = -1;

/* Return the result. */
   return result;
}

static void SetAttrib( AstObject *this_object, const char *setting ) {
/*
*  Name:
*     astSetAttrib

*  Purpose:
*     Set an attribute value for a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     void SetAttrib( AstObject *this, const char *setting )

*  Class Membership:
*     SphMap member function (over-rides the astSetAttrib protected
*     method inherited from the Mapping class).

*  Description:
*     This function assigns an attribute value for a SphMap, the
*     attribute and its value being specified by means of a string of
*     the form:
*
*        "attribute= value "
*
*     Here, "attribute" specifies the attribute name and should be in
*     lower case with no white space present. The value to the right
*     of the "=" should be a suitable textual representation of the
*     value to be assigned and this will be interpreted according to
*     the attribute's data type.  White space surrounding the value is
*     only significant for string attributes.

*  Parameters:
*     this
*        Pointer to the SphMap.
*     setting
*        Pointer to a null-terminated string specifying the new attribute
*        value.
*/

/* Local Variables: */
   AstSphMap *this;              /* Pointer to the SphMap structure */
   int len;                      /* Length of setting string */
   int ival;                     /* Int attribute value */
   int nc;                       /* Number of characters read by astSscanf */

/* Check the global error status. */
   if ( !astOK ) return;

/* Obtain a pointer to the SphMap structure. */
   this = (AstSphMap *) this_object;

/* Obtain the length of the setting string. */
   len = (int) strlen( setting );

/* UnitRadius. */
/* ------- */
   if ( nc = 0,
        ( 1 == astSscanf( setting, "unitradius= %d %n", &ival, &nc ) )
        && ( nc >= len ) ) {
      astSetUnitRadius( this, ival );

/* If the attribute is still not recognised, pass it on to the parent
   method for further interpretation. */
   } else {
      (*parent_setattrib)( this_object, setting );
   }
}

static int TestAttrib( AstObject *this_object, const char *attrib ) {
/*
*  Name:
*     TestAttrib

*  Purpose:
*     Test if a specified attribute value is set for a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     int TestAttrib( AstObject *this, const char *attrib )

*  Class Membership:
*     SphMap member function (over-rides the astTestAttrib protected
*     method inherited from the Mapping class).

*  Description:
*     This function returns a boolean result (0 or 1) to indicate whether
*     a value has been set for one of a SphMap's attributes.

*  Parameters:
*     this
*        Pointer to the SphMap.
*     attrib
*        Pointer to a null-terminated string specifying the attribute
*        name.  This should be in lower case with no surrounding white
*        space.

*  Returned Value:
*     One if a value has been set, otherwise zero.

*  Notes:
*     - A value of zero will be returned if this function is invoked
*     with the global status set, or if it should fail for any reason.
*/

/* Local Variables: */
   AstSphMap *this;             /* Pointer to the SphMap structure */
   int result;                   /* Result value to return */

/* Initialise. */
   result = 0;

/* Check the global error status. */
   if ( !astOK ) return result;

/* Obtain a pointer to the SphMap structure. */
   this = (AstSphMap *) this_object;

/* UnitRadius */
/* ---------- */
   if ( !strcmp( attrib, "unitradius" ) ) {
      result = astTestUnitRadius( this );

/* If the attribute is still not recognised, pass it on to the parent
   method for further interpretation. */
   } else {
      result = (*parent_testattrib)( this_object, attrib );
   }

/* Return the result, */
   return result;
}

static AstPointSet *Transform( AstMapping *this, AstPointSet *in,
                               int forward, AstPointSet *out ) {
/*
*  Name:
*     Transform

*  Purpose:
*     Apply a SphMap to transform a set of points.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     AstPointSet *Transform( AstMapping *this, AstPointSet *in,
*                             int forward, AstPointSet *out )

*  Class Membership:
*     SphMap member function (over-rides the astTransform protected
*     method inherited from the Mapping class).

*  Description:
*     This function takes a SphMap and a set of points encapsulated in a
*     PointSet and transforms the points from Cartesian coordinates to 
*     spherical coordinates.

*  Parameters:
*     this
*        Pointer to the SphMap.
*     in
*        Pointer to the PointSet holding the input coordinate data.
*     forward
*        A non-zero value indicates that the forward coordinate transformation
*        should be applied, while a zero value requests the inverse
*        transformation.
*     out
*        Pointer to a PointSet which will hold the transformed (output)
*        coordinate values. A NULL value may also be given, in which case a
*        new PointSet will be created by this function.

*  Returned Value:
*     Pointer to the output (possibly new) PointSet.

*  Notes:
*     -  A null pointer will be returned if this function is invoked with the
*     global error status set, or if it should fail for any reason.
*     -  The number of coordinate values per point in the input PointSet must
*     match the number of coordinates for the SphMap being applied.
*     -  If an output PointSet is supplied, it must have space for sufficient
*     number of points and coordinate values per point to accommodate the
*     result. Any excess space will be ignored.
*/

/* Local Variables: */
   AstPointSet *result;          /* Pointer to output PointSet */
   AstSphMap *map;               /* Pointer to SphMap to be applied */
   double **ptr_in;              /* Pointer to input coordinate data */
   double **ptr_out;             /* Pointer to output coordinate data */
   int npoint;                   /* Number of points */
   int point;                    /* Loop counter for points */
   double *p0;                   /* Pointer to x axis value */
   double *p1;                   /* Pointer to y axis value */
   double *p2;                   /* Pointer to z axis value */
   double *q0;                   /* Pointer to longitude value */
   double *q1;                   /* Pointer to latitude value */
   double v[3];                  /* Vector for a single point */

/* Check the global error status. */
   if ( !astOK ) return NULL;

/* Obtain a pointer to the SphMap. */
   map = (AstSphMap *) this;

/* Apply the parent mapping using the stored pointer to the Transform member
   function inherited from the parent Mapping class. This function validates
   all arguments and generates an output PointSet if necessary, but does not
   actually transform any coordinate values. */
   result = (*parent_transform)( this, in, forward, out );

/* We will now extend the parent astTransform method by performing the
   calculations needed to generate the output coordinate values. */

/* Determine the numbers of points and coordinates per point from the input
   PointSet and obtain pointers for accessing the input and output coordinate
   values. */
   npoint = astGetNpoint( in );
   ptr_in = astGetPoints( in );      
   ptr_out = astGetPoints( result );

/* Determine whether to apply the forward or inverse mapping, according to the
   direction specified and whether the mapping has been inverted. */
   if ( astGetInvert( map ) ) forward = !forward;

/* Perform coordinate arithmetic. */
/* ------------------------------ */
   if( astOK ){

/* First deal with forward mappings from Cartesian to Spherical. */
      if( forward ){

/* Store pointers to the input Cartesian axes. */
         p0 = ptr_in[ 0 ];
         p1 = ptr_in[ 1 ];
         p2 = ptr_in[ 2 ];

/* Store pointers to the output Spherical axes. */
         q0 = ptr_out[ 0 ];
         q1 = ptr_out[ 1 ];

/* Apply the mapping to every point. */
         for( point = 0; point < npoint; point++ ){
            if( *p0 != AST__BAD && *p1 != AST__BAD && *p2 != AST__BAD ){
               v[0] = *p0;
               v[1] = *p1;
               v[2] = *p2;
               if( v[0] != 0.0 || v[1] != 0.0 || v[2] != 0.0 ){
                  slaDcc2s( v, q0++, q1++ );
               } else {
                  *(q0++) = AST__BAD;
                  *(q1++) = AST__BAD;
               }
            } else {
               *(q0++) = AST__BAD;
               *(q1++) = AST__BAD;
            }
            p0++;
            p1++;
            p2++;
         }

/* Now deal with inverse mappings from Spherical to Cartesian. */
      } else {

/* Store pointers to the input Spherical axes. */
         q0 = ptr_in[ 0 ];
         q1 = ptr_in[ 1 ];

/* Store pointers to the output Cartesian axes. */
         p0 = ptr_out[ 0 ];
         p1 = ptr_out[ 1 ];
         p2 = ptr_out[ 2 ];

/* Apply the mapping to every point. */
         for( point = 0; point < npoint; point++ ){
            if( *q0 != AST__BAD && *q1 != AST__BAD ){
               slaDcs2c( *q0, *q1, v );
               *(p0++) = v[ 0 ];
               *(p1++) = v[ 1 ];
               *(p2++) = v[ 2 ];
            } else {
               *(p0++) = AST__BAD;
               *(p1++) = AST__BAD;
               *(p2++) = AST__BAD;

            }
            q0++;
            q1++;
         }

      }

   }

/* Return a pointer to the output PointSet. */
   return result;
}

/* Functions which access class attributes. */
/* ---------------------------------------- */
/* Implement member functions to access the attributes associated with
   this class using the macros defined for this purpose in the
   "object.h" file. For a description of each attribute, see the class
   interface (in the associated .h file). */

/* UnitRadius */
/* ---------- */
/*
*att++
*  Name:
*     UnitRadius

*  Purpose:
*     SphMap input vectors lie on a unit sphere?

*  Type:
*     Public attribute.

*  Synopsis:
*     Integer (boolean).

*  Description:
*     This is a boolean attribute which indicates whether the
*     3-dimensional vectors which are supplied as input to a SphMap
*     are known to always have unit length, so that they lie on a unit
*     sphere centred on the origin.
*
c     If this condition is true (indicated by setting UnitRadius
c     non-zero), it implies that a CmpMap which is composed of a
c     SphMap applied in the forward direction followed by a similar
c     SphMap applied in the inverse direction may be simplified
c     (e.g. by astSimplify) to become a UnitMap. This is because the
c     input and output vectors will both have unit length and will
c     therefore have the same coordinate values.
f     If this condition is true (indicated by setting UnitRadius
f     non-zero), it implies that a CmpMap which is composed of a
f     SphMap applied in the forward direction followed by a similar
f     SphMap applied in the inverse direction may be simplified
f     (e.g. by AST_SIMPLIFY) to become a UnitMap. This is because the
f     input and output vectors will both have unit length and will
f     therefore have the same coordinate values.
*
*     If UnitRadius is zero (the default), then although the output
*     vector produced by the CmpMap (above) will still have unit
*     length, the input vector may not have. This will, in general,
*     change the coordinate values, so it prevents the pair of SphMaps
*     being simplified.

*  Notes:
*     - This attribute is intended mainly for use when SphMaps are
*     involved in a sequence of Mappings which project (e.g.) a
*     dataset on to the celestial sphere. By regarding the celestial
*     sphere as a unit sphere (and setting UnitRadius to be non-zero)
*     it becomes possible to cancel the SphMaps present, along with
*     associated sky projections, when two datasets are aligned using
*     celestial coordinates. This often considerably improves
*     performance.
*     - Such a situations often arises when interpreting FITS data and
*     is handled automatically by the FitsChan class.
*     - The value of the UnitRadius attribute is used only to control
*     the simplification of Mappings and has no effect on the value of
*     the coordinates transformed by a SphMap. The lengths of the
*     input 3-dimensional Cartesian vectors supplied are always
*     ignored, even if UnitRadius is non-zero.

*  Applicability:
*     SphMap
*        All SphMaps have this attribute.
*att--
*/
astMAKE_CLEAR(SphMap,UnitRadius,unitradius,-1)
astMAKE_GET(SphMap,UnitRadius,int,0,(this->unitradius == -1 ? 0 : this->unitradius))
astMAKE_SET(SphMap,UnitRadius,int,unitradius,( value ? 1 : 0 ))
astMAKE_TEST(SphMap,UnitRadius,( this->unitradius != -1 ))

/* Copy constructor. */
/* ----------------- */
static void Copy( const AstObject *objin, AstObject *objout ) {
/*
*  Name:
*     Copy

*  Purpose:
*     Copy constructor for SphMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Copy( const AstObject *objin, AstObject *objout )

*  Description:
*     This function implements the copy constructor for SphMap objects.

*  Parameters:
*     objin
*        Pointer to the SphMap to be copied.
*     objout
*        Pointer to the SphMap being constructed.

*/

}

/* Destructor. */
/* ----------- */
static void Delete( AstObject *obj ) {
/*
*  Name:
*     Delete

*  Purpose:
*     Destructor for SphMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Delete( AstObject *obj )

*  Description:
*     This function implements the destructor for SphMap objects.

*  Parameters:
*     obj
*        Pointer to the SphMap to be deleted.

*  Notes:
*     - This destructor does nothing and exists only to maintain a
*     one-to-one correspondence between destructors and copy
*     constructors.
*/


}

/* Dump function. */
/* -------------- */
static void Dump( AstObject *this_object, AstChannel *channel ) {
/*
*  Name:
*     Dump

*  Purpose:
*     Dump function for SphMap objects.

*  Type:
*     Private function.

*  Synopsis:
*     void Dump( AstObject *this, AstChannel *channel )

*  Description:
*     This function implements the Dump function which writes out data
*     for the SphMap class to an output Channel.

*  Parameters:
*     this
*        Pointer to the SphMap whose data are being written.
*     channel
*        Pointer to the Channel to which the data are being written.
*/

/* Local Variables: */
   AstSphMap *this;              /* Pointer to the SphMap structure */
   int ival;                     /* Integer value */
   int set;                      /* Attribute value set? */

/* Check the global error status. */
   if ( !astOK ) return;

/* Obtain a pointer to the SphMap structure. */
   this = (AstSphMap *) this_object;

/* Write out values representing the instance variables for the
   SphMap class.  Accompany these with appropriate comment strings,
   possibly depending on the values being written.*/

/* In the case of attributes, we first use the appropriate (private)
   Test...  member function to see if they are set. If so, we then use
   the (private) Get... function to obtain the value to be written
   out.

   For attributes which are not set, we use the astGet... method to
   obtain the value instead. This will supply a default value
   (possibly provided by a derived class which over-rides this method)
   which is more useful to a human reader as it corresponds to the
   actual default attribute value.  Since "set" will be zero, these
   values are for information only and will not be read back. */

/* UnitRadius. */
/* ------- */
   set = TestUnitRadius( this );
   ival = set ? GetUnitRadius( this ) : astGetUnitRadius( this );
   if( ival ) {
      astWriteInt( channel, "UntRd", set, 0, ival, "All input vectors have unit length" );
   } else {
      astWriteInt( channel, "UntRd", set, 0, ival, "Input vectors do not all have unit length" );
   }

}

/* Standard class functions. */
/* ========================= */
/* Implement the astIsASphMap and astCheckSphMap functions using the macros
   defined for this purpose in the "object.h" header file. */
astMAKE_ISA(SphMap,Mapping,check,&class_init)
astMAKE_CHECK(SphMap)

AstSphMap *astSphMap_( const char *options, ... ) {
/*
*++
*  Name:
c     astSphMap
f     AST_SPHMAP

*  Purpose:
*     Create a SphMap.

*  Type:
*     Public function.

*  Synopsis:
c     #include "sphmap.h"
c     AstSphMap *astSphMap( const char *options, ... )
f     RESULT = AST_SPHMAP( OPTIONS, STATUS )

*  Class Membership:
*     SphMap constructor.

*  Description:
*     This function creates a new SphMap and optionally initialises
*     its attributes.
*
*     A SphMap is a Mapping which transforms points from a
*     3-dimensional Cartesian coordinate system into a 2-dimensional
*     spherical coordinate system (longitude and latitude on a unit
*     sphere centred at the origin). It works by regarding the input
*     coordinates as position vectors and finding their intersection
*     with the sphere surface. The inverse transformation always
*     produces points which are a unit distance from the origin
*     (i.e. unit vectors).

*  Parameters:
c     options
f     OPTIONS = CHARACTER * ( * ) (Given)
c        Pointer to a null-terminated string containing an optional
c        comma-separated list of attribute assignments to be used for
c        initialising the new SphMap. The syntax used is identical to
c        that for the astSet function and may include "printf" format
c        specifiers identified by "%" symbols in the normal way.
f        A character string containing an optional comma-separated
f        list of attribute assignments to be used for initialising the
f        new SphMap. The syntax used is identical to that for the
f        AST_SET routine.
c     ...
c        If the "options" string contains "%" format specifiers, then
c        an optional list of additional arguments may follow it in
c        order to supply values to be substituted for these
c        specifiers. The rules for supplying these are identical to
c        those for the astSet function (and for the C "printf"
c        function).
f     STATUS = INTEGER (Given and Returned)
f        The global status.

*  Returned Value:
c     astSphMap()
f     AST_SPHMAP = INTEGER
*        A pointer to the new SphMap.

*  Notes:
*     - The spherical coordinates are longitude (positive
*     anti-clockwise looking from the positive latitude pole) and
*     latitude. The Cartesian coordinates are right-handed, with the x
*     axis (axis 1) at zero longitude and latitude, and the z axis
*     (axis 3) at the positive latitude pole.
*     - At either pole, the longitude is set arbitrarily to zero.
*     - If the Cartesian coordinates are all zero, then the longitude
*     and latitude are set to the value AST__BAD.
*     - A null Object pointer (AST__NULL) will be returned if this
c     function is invoked with the AST error status set, or if it
f     function is invoked with STATUS set to an error value, or if it
*     should fail for any reason.
*--
*/

/* Local Variables: */
   AstSphMap *new;              /* Pointer to new SphMap */
   va_list args;                /* Variable argument list */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* Initialise the SphMap, allocating memory and initialising the
   virtual function table as well if necessary. */
   new = astInitSphMap( NULL, sizeof( AstSphMap ), !class_init, &class_vtab,
                        "SphMap" );

/* If successful, note that the virtual function table has been
   initialised. */
   if ( astOK ) {
      class_init = 1;

/* Obtain the variable argument list and pass it along with the options string
   to the astVSet method to initialise the new SphMap's attributes. */
      va_start( args, options );
      astVSet( new, options, args );
      va_end( args );

/* If an error occurred, clean up by deleting the new object. */
      if ( !astOK ) new = astDelete( new );
   }

/* Return a pointer to the new SphMap. */
   return new;
}

AstSphMap *astSphMapId_( const char *options, ... ) {
/*
*  Name:
*     astSphMapId_

*  Purpose:
*     Create a SphMap.

*  Type:
*     Private function.

*  Synopsis:
*     #include "sphmap.h"
*     AstSphMap *astSphMapId_( const char *options, ... ) 

*  Class Membership:
*     SphMap constructor.

*  Description:
*     This function implements the external (public) interface to the
*     astSphMap constructor function. It returns an ID value (instead
*     of a true C pointer) to external users, and must be provided
*     because astSphMap_ has a variable argument list which cannot be
*     encapsulated in a macro (where this conversion would otherwise
*     occur).
*
*     The variable argument list also prevents this function from
*     invoking astSphMap_ directly, so it must be a re-implementation
*     of it in all respects, except for the final conversion of the
*     result to an ID value.

*  Parameters:
*     As for astSphMap_.

*  Returned Value:
*     The ID value associated with the new SphMap.
*/

/* Local Variables: */
   AstSphMap *new;              /* Pointer to new SphMap */
   va_list args;                /* Variable argument list */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* Initialise the SphMap, allocating memory and initialising the
   virtual function table as well if necessary. */
   new = astInitSphMap( NULL, sizeof( AstSphMap ), !class_init, &class_vtab,
                        "SphMap" );

/* If successful, note that the virtual function table has been
   initialised. */
   if ( astOK ) {
      class_init = 1;

/* Obtain the variable argument list and pass it along with the options string
   to the astVSet method to initialise the new SphMap's attributes. */
      va_start( args, options );
      astVSet( new, options, args );
      va_end( args );

/* If an error occurred, clean up by deleting the new object. */
      if ( !astOK ) new = astDelete( new );
   }

/* Return an ID value for the new SphMap. */
   return astMakeId( new );
}

AstSphMap *astInitSphMap_( void *mem, size_t size, int init,
                           AstSphMapVtab *vtab, const char *name ) {
/*
*+
*  Name:
*     astInitSphMap

*  Purpose:
*     Initialise a SphMap.

*  Type:
*     Protected function.

*  Synopsis:
*     #include "sphmap.h"
*     AstSphMap *astInitSphMap( void *mem, size_t size, int init,
*                               AstSphMapVtab *vtab, const char *name )

*  Class Membership:
*     SphMap initialiser.

*  Description:
*     This function is provided for use by class implementations to initialise
*     a new SphMap object. It allocates memory (if necessary) to accommodate
*     the SphMap plus any additional data associated with the derived class.
*     It then initialises a SphMap structure at the start of this memory. If
*     the "init" flag is set, it also initialises the contents of a virtual
*     function table for a SphMap at the start of the memory passed via the
*     "vtab" parameter.

*  Parameters:
*     mem
*        A pointer to the memory in which the SphMap is to be initialised.
*        This must be of sufficient size to accommodate the SphMap data
*        (sizeof(SphMap)) plus any data used by the derived class. If a value
*        of NULL is given, this function will allocate the memory itself using
*        the "size" parameter to determine its size.
*     size
*        The amount of memory used by the SphMap (plus derived class data).
*        This will be used to allocate memory if a value of NULL is given for
*        the "mem" parameter. This value is also stored in the SphMap
*        structure, so a valid value must be supplied even if not required for
*        allocating memory.
*     init
*        A logical flag indicating if the SphMap's virtual function table is
*        to be initialised. If this value is non-zero, the virtual function
*        table will be initialised by this function.
*     vtab
*        Pointer to the start of the virtual function table to be associated
*        with the new SphMap.
*     name
*        Pointer to a constant null-terminated character string which contains
*        the name of the class to which the new object belongs (it is this
*        pointer value that will subsequently be returned by the astGetClass
*        method).

*  Returned Value:
*     A pointer to the new SphMap.

*  Notes:
*     -  A null pointer will be returned if this function is invoked with the
*     global error status set, or if it should fail for any reason.
*-
*/

/* Local Variables: */
   AstSphMap *new;              /* Pointer to new SphMap */

/* Check the global status. */
   if ( !astOK ) return NULL;

/* Initialise. */
   new = NULL;

/* Initialise a Mapping structure (the parent class) as the first component
   within the SphMap structure, allocating memory if necessary. Specify that
   the Mapping should be defined in both the forward and inverse directions. */
   new = (AstSphMap *) astInitMapping( mem, size, init,
                                       (AstMappingVtab *) vtab, name,
                                       3, 2, 1, 1 );

/* If necessary, initialise the virtual function table. */
/* ---------------------------------------------------- */
   if ( init ) InitVtab( vtab );
   if ( astOK ) {

/* Initialise the SphMap data. */
/* --------------------------- */
/* Are all input vectors of unit length? Store a value of -1 to indicate that 
   no value has yet been set. This will cause a default value of 0 (no, i.e. 
   input vectors are not all of unit length) to be used. */
      new->unitradius = -1;

   }

/* Return a pointer to the new SphMap. */
   return new;
}

AstSphMap *astLoadSphMap_( void *mem, size_t size, int init,
                           AstSphMapVtab *vtab, const char *name,
                           AstChannel *channel ) {
/*
*+
*  Name:
*     astLoadSphMap

*  Purpose:
*     Load a SphMap.

*  Type:
*     Protected function.

*  Synopsis:
*     #include "sphmap.h"
*     AstSphMap *astLoadSphMap( void *mem, size_t size, int init,
*                               AstSphMapVtab *vtab, const char *name,
*                               AstChannel *channel )

*  Class Membership:
*     SphMap loader.

*  Description:
*     This function is provided to load a new SphMap using data read
*     from a Channel. It first loads the data used by the parent class
*     (which allocates memory if necessary) and then initialises a
*     SphMap structure in this memory, using data read from the input
*     Channel.
*
*     If the "init" flag is set, it also initialises the contents of a
*     virtual function table for a SphMap at the start of the memory
*     passed via the "vtab" parameter.

*  Parameters:
*     mem
*        A pointer to the memory into which the SphMap is to be
*        loaded.  This must be of sufficient size to accommodate the
*        SphMap data (sizeof(SphMap)) plus any data used by derived
*        classes. If a value of NULL is given, this function will
*        allocate the memory itself using the "size" parameter to
*        determine its size.
*     size
*        The amount of memory used by the SphMap (plus derived class
*        data).  This will be used to allocate memory if a value of
*        NULL is given for the "mem" parameter. This value is also
*        stored in the SphMap structure, so a valid value must be
*        supplied even if not required for allocating memory.
*
*        If the "vtab" parameter is NULL, the "size" value is ignored
*        and sizeof(AstSphMap) is used instead.
*     init
*        A boolean flag indicating if the SphMap's virtual function
*        table is to be initialised. If this value is non-zero, the
*        virtual function table will be initialised by this function.
*
*        If the "vtab" parameter is NULL, the "init" value is ignored
*        and the (static) virtual function table initialisation flag
*        for the SphMap class is used instead.
*     vtab
*        Pointer to the start of the virtual function table to be
*        associated with the new SphMap. If this is NULL, a pointer
*        to the (static) virtual function table for the SphMap class
*        is used instead.
*     name
*        Pointer to a constant null-terminated character string which
*        contains the name of the class to which the new object
*        belongs (it is this pointer value that will subsequently be
*        returned by the astGetClass method).
*
*        If the "vtab" parameter is NULL, the "name" value is ignored
*        and a pointer to the string "SphMap" is used instead.

*  Returned Value:
*     A pointer to the new SphMap.

*  Notes:
*     - A null pointer will be returned if this function is invoked
*     with the global error status set, or if it should fail for any
*     reason.
*-
*/

#define KEY_LEN 50               /* Maximum length of a keyword */

/* Local Variables: */
   AstSphMap *new;              /* Pointer to the new SphMap */

/* Initialise. */
   new = NULL;

/* Check the global error status. */
   if ( !astOK ) return new;

/* If a NULL virtual function table has been supplied, then this is
   the first loader to be invoked for this SphMap. In this case the
   SphMap belongs to this class, so supply appropriate values to be
   passed to the parent class loader (and its parent, etc.). */
   if ( !vtab ) {
      size = sizeof( AstSphMap );
      init = !class_init;
      vtab = &class_vtab;
      name = "SphMap";
   }

/* Invoke the parent class loader to load data for all the ancestral
   classes of the current one, returning a pointer to the resulting
   partly-built SphMap. */
   new = astLoadMapping( mem, size, init, (AstMappingVtab *) vtab, name,
                         channel );

/* If required, initialise the part of the virtual function table used
   by this class. */
   if ( init ) InitVtab( vtab );

/* Note if we have successfully initialised the (static) virtual
   function table owned by this class (so that this is done only
   once). */
   if ( astOK ) {
      if ( ( vtab == &class_vtab ) && init ) class_init = 1;

/* Read input data. */
/* ================ */
/* Request the input Channel to read all the input data appropriate to
   this class into the internal "values list". */
      astReadClassData( channel, "SphMap" );

/* Now read each individual data item from this list and use it to
   initialise the appropriate instance variable(s) for this class. */

/* In the case of attributes, we first read the "raw" input value,
   supplying the "unset" value as the default. If a "set" value is
   obtained, we then use the appropriate (private) Set... member
   function to validate and set the value properly. */

/* UnitRadius. */
/* ----------- */
      new->unitradius = astReadInt( channel, "untrd", -1 );
      if ( TestUnitRadius( new ) ) SetUnitRadius( new, new->unitradius );

   }

/* If an error occurred, clean up by deleting the new SphMap. */
   if ( !astOK ) new = astDelete( new );

/* Return the new SphMap pointer. */
   return new;
}

/* Virtual function interfaces. */
/* ============================ */
/* These provide the external interface to the virtual functions defined by
   this class. Each simply checks the global error status and then locates and
   executes the appropriate member function, using the function pointer stored
   in the object's virtual function table (this pointer is located using the
   astMEMBER macro defined in "object.h").

   Note that the member function may not be the one defined here, as it may
   have been over-ridden by a derived class. However, it should still have the
   same interface. */
