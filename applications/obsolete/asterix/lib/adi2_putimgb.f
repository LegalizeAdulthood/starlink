      SUBROUTINE ADI2_PUTIMGB( FID, HDU, NDIM, DIMS, DATA, STATUS )
*+
*  Name:
*     ADI2_PUTIMGB

*  Purpose:
*     Write BYTE data to a FITS IMAGE extension

*  Language:
*     Starlink Fortran

*  Invocation:
*     CALL ADI2_PUTIMGB( FID, HDU, NDIM, DIMS, DATA, STATUS )

*  Description:
*     {routine_description}

*  Arguments:
*     FID = INTEGER (given)
*        ADI identifier of FITS file object
*     HDU = CHARACTER*(*) (given)
*        Name of the HDU
*     NDIM = INTEGER (given)
*        Number of dimensions of DATA
*     DIMS[NDIM] = INTEGER (given)
*        Sizes of the dimensions of DATA
*     DATA[] = BYTE (given)
*        Data to write to HDU
*     STATUS = INTEGER (given and returned)
*        The global status.

*  Examples:
*     {routine_example_text}
*        {routine_example_description}

*  Pitfalls:
*     {pitfall_description}...

*  Notes:
*     {routine_notes}...

*  Prior Requirements:
*     {routine_prior_requirements}...

*  Side Effects:
*     {routine_side_effects}...

*  Algorithm:
*     {algorithm_description}...

*  Accuracy:
*     {routine_accuracy}

*  Timing:
*     {routine_timing}

*  External Routines Used:
*     {name_of_facility_or_package}:
*        {routine_used}...

*  Implementation Deficiencies:
*     {routine_deficiencies}...

*  References:
*     ADI Subroutine Guide : http://www.sr.bham.ac.uk/asterix-docs/Programmer/Guides/adi.html

*  Keywords:
*     package:adi, usage:private

*  Copyright:
*     Copyright (C) University of Birmingham, 1995

*  Authors:
*     DJA: David J. Allan (Jet-X, University of Birmingham)
*     {enter_new_authors_here}

*  History:
*     19 Jul 1995 (DJA):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

*  Arguments Given:
      INTEGER                   FID                     ! See above
      CHARACTER*(*)             HDU                     !
      INTEGER                   NDIM                    !
      INTEGER                   DIMS(*)                 !
      BYTE			DATA(*)

*  Status:
      INTEGER 			STATUS             	! Global status

*  Local Variables:
      INTEGER                   FSTAT                   ! FITSIO status
      INTEGER                   HID                     ! HDU identifier
      INTEGER                   LUN                     ! Logical unit
      INTEGER			NELEM			! Total # elements
*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Locate the HDU buffer
      CALL ADI2_MOVHDU( FID, HDU, HID, STATUS )

*  Get logical unit
      CALL ADI2_GETLUN( FID, LUN, STATUS )

*  Find total number of elements
      CALL ARR_SUMDIM( NDIM, DIMS, NELEM )

*  Write the data
      FSTAT = 0
      CALL FTPPRB( LUN, 1, 1, NELEM, DATA, STATUS )

*  Free the buffer
      CALL ADI_ERASE( HID, STATUS )

*  Report any errors
      IF ( STATUS .NE. SAI__OK ) THEN
        CALL AST_REXIT( 'ADI2_PUTIMGB', STATUS )
      END IF

      END
