/*
*+
*  Name:
*     MESSYS_LEN

*  Purpose:
*     .H - Data definitions for message structure

*  Language:
*     {routine_language}

*  Copyright:
*     Copyright (C) 1994 Science & Engineering Research Council. All
*     Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA
*     02111-1307, USA

*  Authors:
*     {original_author_entry}

*  History:
*     11-APR-1994 (BDK):
*        Remove definition of EXT_ macros
*     13-APR-1994 (BDK):
*        Remove structure definitions
*     07-JUL-1994 (AJC):
*        Renamed from MESSYS_DD
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
*/

#ifndef INT_BYTE_SIZE

#define INT_BYTE_SIZE	(sizeof(int))
#define MSG_LEN 500		/* length of message in bytes (from DDPATH) */
				/* Must be divisible by INT_BYTE_SIZE       */
				/* If this is changed, MESSDEFN must also be */
				/* changed */
#define MSG_NAME_LEN	32
#ifndef MSG_FIX_LEN
#  define MSG_FIX_LEN	(6*INT_BYTE_SIZE+MSG_NAME_LEN)
				/* length of non-value part of non-path part */
#endif /* #ifndef MSG_FIX_LEN */

#define MSG_VAL_LEN	(MSG_LEN - MSG_FIX_LEN)
				/* length of value part of message */

#endif /* #ifndef INT_BYTE_SIZE */
