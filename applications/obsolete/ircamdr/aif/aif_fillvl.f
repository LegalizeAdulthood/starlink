*+  AIF_FILLVL - Fill a vectorised LOGICAL array with a given value
      SUBROUTINE AIF_FILLVL( VALUE, DIM, ARRAY, STATUS )
*    Description :
*     The vectorised array ARRAY( DIM ) of type LOGICAL is filled with
*     the given LOGICAL value VALUE.
*    Invocation :
*     CALL AIF_FILLVL( VALUE, DIM, ARRAY, STATUS )
*    Parameters :
*     VALUE         = LOGICAL( READ )
*           The value to fill the array with
*     DIM           = INTEGER( READ )
*           The size of the array to be filled. (i.e. the product of
*           the dimensions of ARRAY).
*     ARRAY( DIM ) = LOGICAL( WRITE )
*           Array to be filled with VALUE
*     STATUS        = INTEGER( READ )
*           This is the global status, if STATUS has an error value on entry
*           to the routine then an immediate return will occur.
*    Method :
*     If no error on entry then
*        Loop through all the elements of the array
*           set the array element to the given value
*        Endloop
*     Endif
*    Authors :
*     Steven Beard (ROE::SMB)
*    History :
*     30/06/1984 : Original version                   (ROE::SMB)
*    Type Definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
*    Import :
      LOGICAL
     :  VALUE         ! value to fill array with
      INTEGER
     :  DIM           ! size of array
*    Export :
      LOGICAL
     :  ARRAY( DIM )  ! data array to be filled
*    Status :
      INTEGER STATUS
*    Local variables :
      INTEGER
     :  I             ! index to array elements
*-

*    check for error on entry
      IF( STATUS .EQ. SAI__OK ) THEN

*      Fill the array with the value of VALUE
         DO I = 1,DIM
            ARRAY( I ) = VALUE
         ENDDO

      ENDIF

      END
