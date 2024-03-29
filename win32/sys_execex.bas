#include "../fb.bi"
#include "fb_private_console.bi"
#include "crt/process.bi"

/' !!!FIXME!!! return type should be ANY PTR (aka INTEGER) sized for 32/64-bit '/

extern "C"
function fb_ExecEx FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr, do_fork as long ) as long
	dim as ubyte buffer(MAX_PATH + 1)
	dim as ZString Ptr arguments
	dim as long res = 0
	dim as size_t len_arguments
	dim as size_t len_program

	dim as Boolean got_program = (program <> NULL) andalso (program->data <> NULL)

	if ( got_program = False ) then
		fb_hStrDelTemp( args )
		fb_hStrDelTemp( program )
		return -1
	end if

	fb_hGetShortPath( program->data, @buffer(0), cast(ssize_t, MAX_PATH) )

	len_program = strlen( @buffer(0) )
	len_arguments = iif( ( args=NULL ) , 0, FB_STRSIZE( args ) )

	arguments = allocate( len_program + len_arguments + 2 )
	DBG_ASSERT( arguments <> NULL )

	FB_MEMCPY( arguments, @buffer(0), len_program )
	arguments[len_program] = Asc(" ")
	if ( len_arguments <> 0 ) then
		FB_MEMCPY( arguments + len_program + 1, args->data, len_arguments )
	end if
	arguments[len_program + len_arguments + 1] = 0

	FB_STRLOCK()

	fb_hStrDelTemp_NoLock( args )
	fb_hStrDelTemp_NoLock( program )

	FB_STRUNLOCK()

	FB_CON_CORRECT_POSITION()

	scope
		dim as STARTUPINFO _StartupInfo
		dim as PROCESS_INFORMATION ProcessInfo
		memset( @_StartupInfo, 0, sizeof(_StartupInfo) )
		_StartupInfo.cb = sizeof(_StartupInfo)

		if ( CreateProcess( NULL,         						/' application name - correct! '/ _
				arguments,   						/' command line '/ _
				NULL, NULL,  						/' default security descriptors '/ _
				FALSE,       						/' don't inherit handles '/ _
				CREATE_DEFAULT_ERROR_MODE, 	/' do we really need this? '/ _
				NULL,        						/' default environment '/ _
				NULL,        						/' current directory '/ _
				@_StartupInfo, _
				@ProcessInfo ) = FALSE ) then
			res = -1
		else
			/' Release main thread handle - we're not interested in it '/
			CloseHandle( ProcessInfo.hThread )
			if ( do_fork <> NULL ) then
				dim as DWORD dwExitCode
				WaitForSingleObject( ProcessInfo.hProcess, INFINITE )
				if ( GetExitCodeProcess( ProcessInfo.hProcess, @dwExitCode ) = FALSE ) then
					res = -1
				else
					res = cast(long, dwExitCode)
				end if
				CloseHandle( ProcessInfo.hProcess )
			else
				'' res = cast(long, ProcessInfo.hProcess)
				'' fbc complains trying to cast ANY PTR to LONG on 64-bit.
				res = cast(long, cast(integer, ProcessInfo.hProcess))
				
			end if
		end if
	end scope

	deallocate( arguments )

	return res
end function
end extern
