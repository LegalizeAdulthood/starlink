/*
 * tclAppInit.c --
 *
 *	Provides a default version of the Tcl_AppInit procedure.
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef lint
static char sccsid[] = "@(#) tclAppInit.c 1.11 94/12/17 16:14:03";
#endif /* not lint */

#include "tcl.h"
#include "tclAdam.h"
#include "tclIrafio.h"

/*
 * The following variable is a special hack that is needed in order for
 * Sun shared libraries to be used for Tcl.
 */

#ifdef NEED_MATHERR
extern int matherr();
int *tclDummyMathPtr = (int *) matherr;
#endif

extern int ems1_starf_c( char *path,
                         char *filename,
                         char *mode,
                         char **found,
                         int *pathlen );

char * tcl_RcFileName;

/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in interp->result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */

int
Tcl_AppInit(interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{
    int pathlen;                /* ignored - length of found filename */
    if (Tcl_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

    /*
     * Call the init procedures for included packages.  Each call should
     * look like this:
     *
     * if (Mod_Init(interp) == TCL_ERROR) {
     *     return TCL_ERROR;
     * }
     *
     * where "Mod" is the name of the module.
     */

    /*
     * Call Tcl_CreateCommand for application-specific commands, if
     * they weren't already created by the init procedures called above.
     */
    if (Tcladam_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }
    if (Tclirafio_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

    /*
     * Specify a user-specific startup file to invoke if the application
     * is run interactively.  Typically the startup file is "~/.apprc"
     * where "app" is the name of the application.  If this line is deleted
     * then no user-specific startup file will be run under any conditions.
     */

    /* Attempt to find the file along ADAMADAP_PATH */
     if ( !ems1_starf_c(
       "ADAMADAP_PATH", "adamadap.tcl", "r", &tcl_RcFileName , &pathlen ) ) {

    /*   if unsuccessful, try relative to PATH */
     if ( !ems1_starf_c(
        "PATH", "../iraf/irafstar/adamadap.tcl", "r", &tcl_RcFileName, &pathlen ) )

    /*   as a last resort, use /star/iraf/irafstar */
         tcl_RcFileName = "/star/iraf/irafstar/adamadap.tcl";
     }

     Tcl_SetVar(interp, "tcl_rcFileName", tcl_RcFileName, TCL_GLOBAL_ONLY);

     return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tcl_Main never returns here, so this procedure never
 *	returns either.
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */

int
main(argc, argv)
    int argc;			/* Number of command-line arguments. */
    char **argv;		/* Values of command-line arguments. */
{
    Tcl_Main(argc, argv, Tcl_AppInit);
    return 0;			/* Needed only to prevent compiler warning. */
}
