      SUBROUTINE ATL1_GTOBJ( PARAM, CLASS, ISA, IAST, STATUS )
*+
*  Name:
*     ATL1_GTOBJ

*  Purpose:
*     Get an AST Object from an NDF or text file using an environment 
*     parameter.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL ATL1_GTOBJ( PARAM, CLASS, ISA, IAST, STATUS )

*  Description:

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The parameter name.
*     CLASS = CHARACTER * ( * ) (Given)
*        The required class. Used in error reports (see ISA).
*     ISA = EXTERNAL (Given)
*        A suitable AST "ISA.." function which returns .TRUE. if an Object
*        is of a suitable class. This is ignored if CLASS is blank.
*        Otherwise, an error is reported if th supplied Object is not of the
*        required class.
*     IAST = INTEGER (Returned)
*        The AST Object, or AST__NULL.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Authors:
*     DSB: David Berry (STARLINK)
*     {enter_new_authors_here}

*  History:
*     12-JAN-2001 (DSB):
*        Original version.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
      
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'AST_PAR'          ! AST constants
      INCLUDE 'NDF_PAR'          ! NDF constants

*  Arguments Given:
      CHARACTER PARAM*(*)
      CHARACTER CLASS*(*)
      LOGICAL ISA

*  Arguments Returned:
      INTEGER IAST

*  Status:
      INTEGER STATUS             ! Global status

*  External References:
      EXTERNAL ISA

*  Local Variables:
      INTEGER INDF
*.

*  Initialise.
      IAST = AST__NULL

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Attempt to access the parameter as an NDF.
      CALL NDF_EXIST( PARAM, 'READ', INDF, STATUS )

*  If succesful, get the WCS FrameSet from it, and annul the NDF identifier.
      IF( INDF .NE. NDF__NOID ) THEN
         CALL KPG1_GTWCS( INDF, IAST, STATUS )
         CALL NDF_ANNUL( INDF, STATUS )

*  If it was not an NDF, attempt to read an AST FrameSet from it
*  as a text file.
      ELSE
         CALL ATL1_ASSOC( PARAM, IAST, STATUS )

      END IF

*  Check the Object class if CLASS is not blank.
      IF( CLASS .NE. ' ' .AND. STATUS .EQ. SAI__OK ) THEN 
         IF( .NOT. ISA( IAST, STATUS ) ) THEN
            CALL MSG_SETC( 'C', AST_GETC( IAST, 'CLASS', STATUS ) )
            CALL MSG_SETC( 'P', PARAM )
            CALL MSG_SETC( 'L', CLASS )
            STATUS = SAI__ERROR
            CALL ERR_REP( 'ATL1_GTOBJ_ERR1', '$^P contains a ^C. '//
     :                 'A ^L is required.', STATUS )
         END IF
      END IF

*  Annul the object if an error occurred.
      IF( STATUS .NE. SAI__OK ) CALL AST_ANNUL( IAST, STATUS )

      END
