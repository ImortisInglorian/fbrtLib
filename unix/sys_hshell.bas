/' SHELL command '/

#include "../fb.bi"
#include "fb_private_console.bi"
#include "sys/wait.bi"

Extern "c"
Function fb_hShell( program as ubyte ptr ) as long

	dim errcode as long

	FB_LOCK( )
	fb_hExitConsole()
	FB_UNLOCK( )

	errcode = system( program )

	/' system() result uses same format as the status
	   returned by waitpid(), or -1 on error '/
	if( ( errcode <> -1 ) AndAlso WIFEXITED( errcode ) ) then
		errcode = WEXITSTATUS( errcode )
		if( errcode = 127 ) then
			/' /bin/sh could not be executed '/
			/' FIXME: can't tell difference if /bin/sh returned 127 '/
			errcode = -1
		end if
	end if

	FB_LOCK( )
	fb_hInitConsole()
	FB_UNLOCK( )

	return errcode
End Function
End Extern
