      SUBROUTINE ARY1_MPSR( IACB, LOC, TYPE, MODE, BAD, MLOC, COPY,
     :                      PNTR, DCE, STATUS )
*+
*  Name:
*     ARY1_MPSR

*  Purpose:
*     Map a simple array component for READ (or UPDATE) access.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL ARY1_MPSR( IACB, LOC, TYPE, MODE, BAD, MLOC, COPY, PNTR, DCE,
*     STATUS )

*  Description:
*     The routine maps a component (non-imaginary or imaginary) of a
*     simple array for READ (or UPDATE) access and returns a locator
*     and a pointer to the mapped data.

*  Arguments:
*     IACB = INTEGER (Given)
*        Index to an entry in the ACB specifying the array whose data
*        are to be mapped.
*     LOC = CHARACTER * ( * ) (Given)
*        Locator to the array component (non-imaginary or imaginary) to
*        be accessed.
*     TYPE = CHARACTER * ( * ) (Given)
*        The data type for access (case insensitive).
*     MODE = CHARACTER * ( * ) (Given)
*        The mode of access required; either 'READ' or 'UPDATE' (case
*        insensitive).
*     BAD = LOGICAL (Given)
*        Whether it is necessary to check for "bad" values during data
*        type conversion.
*     MLOC = CHARACTER * ( * ) (Returned)
*        Locator associated with the data object which is mapped to
*        provide memory locations for the data.
*     COPY = LOGICAL (Returned)
*        Whether the mapped data region is a "copy" of the actual data
*        (as opposed to being a mapped slice of the data object
*        itself).
*     PNTR = INTEGER (Returned)
*        Pointer to the mapped data.
*     DCE = LOGICAL (Returned)
*        Whether a data conversion error occurred.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     -  This routine may also be used to map primitive arrays.

*  Prior requirements:
*     -  Appropriate entries relating to the region of data to be mapped
*     must already have been set up in the MCB before this routine is
*     called.
*     -  Type, bounds and dimensionality information for the data object
*     being mapped must already be available in the DCB.

*  Algorithm:
*     -  Set an initial value for the MLOC argument before checking the
*     inherited status.
*     -  Obtain indices into the DCB and MCB and initialise.
*     -  Calculate the size of the mapping region in each dimension and
*     the total number of data elements to be mapped.
*     -  If appropriate, map the whole data component directly using
*     HDS.
*     -  Otherwise, if appropriate, locate a slice containing the
*     required subregion of the data component and map this directly
*     using HDS.
*     -  Otherwise, if appropriate, create and map a temporary object
*     and read the required subregion into it, padding any surrounding
*     region with "bad" values.
*     -  Otherwise, if no mapping transfer region exists, then create
*     and map a temporary object and fill it with "bad" values.

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK)
*     {enter_new_authors_here}

*  History:
*     27-JUN-1989 (RFWS):
*        Original version.
*     2-MAR-1990 (RFWS):
*        Added initialisation of the MLOC argument.
*     21-MAR-1990 (RFWS):
*        Changed to pass the maximum dimensionality (of the data object
*        and mapped array) to ARY1_GTN.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'DAT_PAR'          ! DAT_ public constants
      INCLUDE 'ARY_PAR'          ! ARY_ public constants
      INCLUDE 'ARY_CONST'        ! ARY_ private constants

*  Global Variables:
      INCLUDE 'ARY_DCB'          ! ARY_ Data Control Block
*        DCB_LBND( ARY__MXDIM, ARY__MXDCB ) = INTEGER (Read)
*           Lower bounds of data object.
*        DCB_NDIM( ARY__MXDCB ) = INTEGER (Read)
*           Number of data object dimensions.
*        DCB_TYP( ARY__MXDCB ) = CHARACTER * ( ARY__SZTYP ) (Read)
*           Array data type.
*        DCB_UBND( ARY__MXDIM, ARY__MXDCB ) = INTEGER (Read)
*           Upper bounds of data object.

      INCLUDE 'ARY_ACB'          ! ARY_ Access Control Block
*        ACB_IDCB( ARY__MXACB ) = INTEGER (Read)
*           Index to data object entry in the DCB.
*        ACB_IMCB( ARY__MXACB ) = INTEGER (Read)
*           Index to mapping entry in the MCB.
*        ACB_NDIM( ARY__MXACB ) = INTEGER (Read)
*           Number of access dimensions.

      INCLUDE 'ARY_MCB'          ! ARY_ Mapping Control Block
*        MCB_LMRB( ARY__MXDIM, ARY__MXMCB ) = INTEGER (Read)
*           Lower bounds of mapping region.
*        MCB_LMTR( ARY__MXDIM, ARY__MXMCB ) = INTEGER (Read)
*           Lower bounds of the mapping transfer region.
*        MCB_MRFUL( ARY__MXMCB ) = LOGICAL (Read)
*           Whether the mapping transfer region completely fills the
*           mapping region.
*        MCB_MTREX( ARY__MXMCB ) = LOGICAL (Read)
*           Whether a mapping transfer region exists.
*        MCB_UMRB( ARY__MXDIM, ARY__MXMCB ) = INTEGER (Read)
*           Upper bounds of mapping region.
*        MCB_UMTR( ARY__MXDIM, ARY__MXMCB ) = INTEGER (Read)
*           Upper bounds of the mapping transfer region.
*        MCB_WHOLE( ARY__MXMCB ) = LOGICAL (Read)
*           Whether the whole data component is to be accessed.

*  Arguments Given:
      INTEGER IACB
      CHARACTER * ( * ) LOC
      CHARACTER * ( * ) TYPE
      CHARACTER * ( * ) MODE
      LOGICAL BAD

*  Arguments Returned:
      CHARACTER * ( * ) MLOC
      LOGICAL COPY
      INTEGER PNTR
      LOGICAL DCE

*  Status:
      INTEGER STATUS             ! Global status

*  External references:
      LOGICAL CHR_SIMLR          ! Case insensitive string comparison

*  Local variables:
      INTEGER DIM( ARY__MXDIM )  ! Dimensions of mapping region
      INTEGER DIML( ARY__MXDIM ) ! Lower bounds of slice
      INTEGER DIMU( ARY__MXDIM ) ! Upper bounds of slice
      INTEGER EL                 ! Number of data elements to be mapped
      INTEGER I                  ! Loop counter for dimensions
      INTEGER IDCB               ! Index to entry in DCB
      INTEGER IMCB               ! Index to entry in MCB
      INTEGER NDIMA              ! Number of access dimensions
      INTEGER NDIMD              ! Number of data object dimensions

*.

*  Set an initial value for the MLOC argument.
      MLOC = ARY__NOLOC

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Obtain indices into the DCB and MCB.
      IDCB = ACB_IDCB( IACB )
      IMCB = ACB_IMCB( IACB )

*  Obtain the number of access dimensions and the number of actual data
*  object dimensions.
      NDIMA = ACB_NDIM( IACB )
      NDIMD = DCB_NDIM( IDCB )

*  Calculate the size of the mapping region in each dimension and the
*  total number of data elements to be mapped.
      EL = 1
      DO 1 I = 1, MAX( NDIMA, NDIMD )
         DIM( I ) = MCB_UMRB( I, IMCB ) - MCB_LMRB( I, IMCB ) + 1
         EL = EL * DIM( I )
1     CONTINUE

*  If the mapping region (and mapping transfer region) comprises the
*  whole data object and no data type conversion is required, then clone
*  a locator to the entire data component and map it for access directly
*  using HDS.
      IF ( MCB_WHOLE( IMCB ) .AND.
     :     CHR_SIMLR( TYPE, DCB_TYP( IDCB ) ) ) THEN
         CALL DAT_CLONE( LOC, MLOC, STATUS )
         CALL DAT_MAP( MLOC, TYPE, MODE, NDIMD, DIM, PNTR, STATUS )
         COPY = .FALSE.
         DCE = .FALSE.

*  Otherwise, if the mapping transfer region fills the mapping region
*  and the data component dimensionality does not exceed the maximum
*  dimensionality of an HDS slice and no data type conversion is
*  required, then a slice of the data can be mapped directly using HDS.
      ELSE IF ( MCB_MRFUL( IMCB ) .AND.
     :          ( NDIMD .LE. ARY__MXHSL ) .AND.
     :          CHR_SIMLR( TYPE, DCB_TYP( IDCB ) ) ) THEN

*  Calculate the bounds of the data component slice required.
         DO 2 I = 1, NDIMD
            DIML( I ) = MCB_LMRB( I, IMCB ) - DCB_LBND( I, IDCB ) + 1
            DIMU( I ) = MCB_UMRB( I, IMCB ) - DCB_LBND( I, IDCB ) + 1
2        CONTINUE

*  Locate the slice and map it.
         CALL DAT_SLICE( LOC, NDIMD, DIML, DIMU, MLOC, STATUS )
         CALL DAT_MAP( MLOC, TYPE, MODE, NDIMD, DIM, PNTR, STATUS )
         COPY = .FALSE.
         DCE = .FALSE.

*  Otherwise, if the mapping transfer region doesn't fill the mapping
*  region, but it nevertheless exists, then the mapped data will be
*  surrounded by "bad" values, so a copy must be made.
      ELSE IF ( MCB_MTREX( IMCB ) ) THEN

*  Create and map a temporary object, then read the data in the mapping
*  transfer region into it, padding the rest of the mapped array with
*  "bad" values.
         CALL ARY1_CMTMP( TYPE, NDIMA, DIM, MLOC, PNTR, STATUS )
         CALL ARY1_GTN( BAD, DCB_TYP( IDCB ), LOC, MAX( NDIMA, NDIMD ),
     :                  DCB_LBND( 1, IDCB ), DCB_UBND( 1, IDCB ),
     :                  MCB_LMTR( 1, IMCB ), MCB_UMTR( 1, IMCB ),
     :                  TYPE, MCB_LMRB( 1, IMCB ), MCB_UMRB( 1, IMCB ),
     :                  .TRUE., PNTR, DCE, STATUS )
         COPY = .TRUE.

*  In all other cases, there is no data to be transferred, so simply
*  create and map a temporary object and fill it with "bad" values.
      ELSE
         CALL ARY1_CMTMP( TYPE, NDIMA, DIM, MLOC, PNTR, STATUS )
         CALL ARY1_VBAD( TYPE, EL, PNTR, STATUS )
         COPY = .TRUE.
         DCE = .FALSE.
      END IF
       
*  Call error tracing routine and exit.
      IF ( STATUS .NE. SAI__OK ) CALL ARY1_TRACE( 'ARY1_MPSR', STATUS )

      END
