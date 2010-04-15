      BLOCK DATA I90_INIT
*+
*  Name:
*     I90_INIT

*  Purpose:
*     Initialise the common blocks accessed through include file
*     I90_DAT.

*  Language:
*     Starlink Fortran 77

*  Type of Module:
*     BLOCK DATA

*  Description:
*     The routine initialises common blocks which hold arrays of
*     constants relating to the IRAS satellite and mission. The
*     variables and common blocks used to hold the constants are
*     declared within I90_COM.FOR. Applications make them accessable by
*     including the file I90_DAT. I90_DAT itself includes I90_COM (as
*     well as I90_PAR which sets up scalar constants) and initialises
*     the common blocks using an EXTERNAL statement which references
*     this BLOCK DATA module.
*
*     The values stored in these arrays are described in the file
*     I90_COM.FOR.

*  Authors:
*     DSB: D.S. Berry (STARLINK)
*     {enter_new_authors_here}

*  History:
*     15-MAY-1992 (DSB):
*        Original Version
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'I90_PAR'          ! Scalar constants relating to the IRAS
                                 ! satellite and mission.

*  Global Variables:
      INCLUDE 'I90_COM'          ! Common blocks holding arrays of
                                 ! IRAS related constants.

*  Global Data:

*----------------------------------------------------------------------
*  Dead and small detectors.

      DATA
     : I90__DEAD / 17, 20, 36 /,
     : I90__SMALL/ 11, 12, 26, 27, 31, 38, 39, 46, 47, 54, 55, 62 /


*----------------------------------------------------------------------
*  Data values - per waveband:

      DATA
     : I90__BANDW / 13.48E12,  5.16E12,  2.58E12,   1.00E12 /,
     : I90__BNEFD /    0.105,    0.125,    0.170,     0.580 /,
     : I90__DY    /     0.76,     0.76,     1.51,      3.03 /,
     : I90__DZ    /     4.55,     4.65,     4.75,      5.05 /,
     : I90__NDETS /       16,       15,       16,        15 /,
     : I90__JY    /     7.42,    19.38,    38.76,    100.00 /,
     : I90__OCT84 /     0.97,     0.98,     0.93,      0.74 /,
     : I90__SRATE /       16,       16,        8,         4 /,
     : I90__WAVEL /       12,       25,       60,       100 /,
     : I90__CWVEL /       50,      100 /


*----------------------------------------------------------------------
*  Detector numbers:

      DATA
     : I90__BDETS/ 47,27,51,23,48,28,52,24,49,29,53,25,50,30,54,26,
     :            39,19,43,16,40,20,44,17,41,21,45,18,42,22,46, 0,
     :            31,12,35, 8,32,13,36, 9,33,14,37,10,34,15,38,11,
     :            55, 4,59, 1,56, 5,60, 2,57, 6,61, 3,58, 7,62, 0/

      DATA
     : I90__XDETS/ 47,31,39,55,27,12,19, 4,51,35,43,59,23, 8,16, 1,
     :             48,32,40,56,28,13,20, 5,52,36,44,60,24, 9,17, 2,
     :             49,33,41,57,29,14,21, 6,53,37,45,61,25,10,18, 3,
     :             50,34,42,58,30,15, 7,22,54,38,62,46,11,26/


*----------------------------------------------------------------------
*  Data values - per detector:

      DATA
     : I90__DBAND/   4,     4,     4,     4,     4,     4,     4,
     :               3,     3,     3,     3,     3,     3,     3,     3,
     :               2,     2,     2,     2,     2,     2,     2,
     :               1,     1,     1,     1,     1,     1,     1,     1,
     :               3,     3,     3,     3,     3,     3,     3,     3,
     :               2,     2,     2,     2,     2,     2,     2,     2,
     :               1,     1,     1,     1,     1,     1,     1,     1,
     :               4,     4,     4,     4,     4,     4,     4,     4/

      DATA
     : I90__DETDY/3.03,  3.03,  3.03,  3.03,  3.03,  3.03,  3.03,
     :            1.51,  1.51,  1.51,  1.51,  1.51,  1.51,  1.51,  1.51,
     :            0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,
     :            0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,
     :            1.51,  1.51,  1.51,  1.51,  1.51,  1.51,  1.51,  1.51,
     :            0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,
     :            0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,  0.76,
     :            3.03,  3.03,  3.03,  3.03,  3.03,  3.03,  3.03,  3.03/

      DATA
     : I90__DETDZ/5.05,  5.05,  5.05,  4.68,  5.05,  5.05,  5.05,
     :            4.75,  4.75,  4.75,  1.30,  3.45,  4.75,  4.75,  4.75,
     :            4.65,  4.65,  4.65,  4.48,  4.65,  4.65,  4.48,
     :            4.45,  4.45,  4.45,  1.20,  3.33,  4.55,  4.55,  4.55,
     :            1.28,  4.75,  4.75,  4.75,  4.75,  4.75,  4.75,  3.47,
     :            2.33,  4.65,  4.65,  4.65,  4.65,  4.65,  4.65,  2.33,
     :            1.18,  4.55,  4.55,  4.55,  4.55,  4.55,  4.55,  3.36,
     :            2.52,  5.05,  5.05,  5.05,  5.05,  5.05,  5.05,  2.53/

      DATA
     : I90__DETGP/ 3, 3, 3, 2, 3, 3, 3,
     :             3, 3, 3, 1, 2, 3, 3, 3,
     :             3, 3, 3, 2, 3, 3, 2,
     :             3, 3, 3, 1, 2, 3, 3, 3,
     :             1, 3, 3, 3, 3, 3, 3, 2,
     :             1, 3, 3, 3, 3, 3, 3, 1,
     :             1, 3, 3, 3, 3, 3, 3, 2,
     :             1, 3, 3, 3, 3, 3, 3, 1/

      DATA
     : I90__DETY/27.87, 27.80, 27.86, 23.83, 24.04, 23.65, 23.78,
     :           19.64, 19.72, 19.74, 19.70, 17.20, 17.19, 17.20, 17.20,
     :           14.01, 14.04, 14.04, 12.24, 12.27, 12.26, 12.27,
     :            9.47,  9.46,  9.47,  9.48,  7.71,  7.71,  7.70,  7.71,
     :            4.56,  4.59,  4.58,  4.59,  2.06,  2.06,  2.11,  2.10,
     :           -1.16, -1.16, -1.16, -1.14, -2.92, -2.92, -2.93, -2.92,
     :           -5.67, -5.67, -5.67, -5.66, -7.42, -7.43, -7.43, -7.42,
     :          -11.33,-11.42,-11.51,-11.41,-15.34,-15.49,-15.40,-15.38/

      DATA
     : I90__DETZ/ 8.71,  0.04, -8.62, 12.86,  4.37, -4.29,-12.77,
     :            9.80,  1.14, -7.53,-14.46, 13.49,  5.47, -3.20,-11.86,
     :            8.71,  0.04, -8.62, 12.96,  4.37, -4.29,-12.88,
     :            9.81,  1.14, -7.52,-14.50, 13.55,  5.47, -3.19,-11.86,
     :           14.55,  7.61, -1.06, -9.73, 11.94,  3.27, -5.40,-13.41,
     :           14.05,  6.55, -2.12,-10.78, 10.88,  2.22, -6.45,-13.95,
     :           14.64,  7.65, -1.02, -9.68, 11.98,  3.32, -5.35,-13.41,
     :           13.95,  6.55, -2.12,-10.79, 10.88,  2.21, -6.46,-13.85/

      DATA
     : I90__DNEFD/0.75,  0.45,  0.45,  0.65,  0.75,  0.45,  0.65,
     :            0.16,  0.19,  0.16,  0.14,  0.19,  0.16,  0.16,  0.16,
     :            0.14,  0.00,  0.14,  0.12,  0.00,  0.12,  0.14,
     :            0.12,  0.09,  0.29,  0.12,  0.12,  0.16,  0.12,  0.12,
     :            0.16,  0.16,  0.21,  0.19,  0.16,  0.00,  0.16,  0.16,
     :            0.09,  0.14,  0.12,  0.24,  0.14,  0.14,  0.12,  0.09,
     :            0.09,  0.12,  0.09,  0.09,  0.09,  0.09,  0.09,  0.09,
     :            0.55,  0.65,  0.55,  0.55,  0.45,  0.75,  0.55,  0.45/

      DATA
     : I90__SOLAN/14.1,  13.7,  12.9,  13.1,
     :            13.2,  13.2,  13.6,
     :            6.10,  6.04,  6.07,  1.92,
     :            4.85,  6.10,  6.19,  6.56,
     :            3.39,   0.0,  3.46,  3.40,
     :             0.0,  3.48,  3.38,
     :            3.21,  3.22,  3.17,  0.92,
     :            2.41,  2.95,  3.25,  3.25,
     :            1.97,  6.40,  6.32,  6.25,
     :            6.36,   0.0,  6.37,  4.84,
     :            1.82,  3.50,  3.44,  3.48,
     :            3.50,  3.45,  3.46,  1.78,
     :            0.89,  3.31,  3.22,  3.29,
     :            3.25,  3.19,  3.24,  2.45,
     :             7.9,  13.3,  14.0,  12.9,
     :            14.0,  13.8,  14.2,   6.8/

*.

      END
