/' Dynamic library loading functions '/

#include "../fb.bi"
#include "fb_private_console.bi"
#include "dlfcn.bi"

Extern "C"
Function fb_DylibLoad FBCALL( library as FBSTRING ptr ) As Any Ptr

	dim res as Any ptr = NULL
	dim i as long
	dim libname as ubyte(0 To MAX_PATH)
	// Sometimes you will see .so files on Darwin too
	dim libnameformat(0 To 8) as ubyte ptr = { sadd("%s"), _
							  sadd("lib%s"), _
#ifdef HOST_DARWIN
							  sadd("lib%s.dylib"), _
#endif
							  sadd("lib%s.so"), _
							  sadd("./%s"), _
							  sadd("./lib%s"), _
#ifdef HOST_DARWIN
							  sadd("./lib%s.dylib"), _
#endif
							  sadd("./lib%s.so"), _
							  NULL }
	dim libnameformatptr as ubyte ptr ptr = @libnameformat(0)

	/' Just in case the shared lib is an FB one, temporarily reset the
	   terminal, to let the 2nd rtlib capture the original terminal state.
	   That way both rtlibs can restore the terminal properly on exit.
	   Note: The shared lib rtlib exits *after* the program rtlib, in case
	   the user forgot to dylibfree(). '/
	FB_LOCK( )
	fb_hExitConsole()
	FB_UNLOCK( )

	libname[MAX_PATH-1] = 0
	if( ( library <> Null ) AndAlso (library->data <> Null ) ) then
		While *libnameformatptr
			snprintf( @libname(0), MAX_PATH-1, *libnameformatptr, library->data )
			fb_hConvertPath( libname )
			res = dlopen( libname, RTLD_LAZY )
			if( res ) then Exit While
			libnameformatptr += 1
		Wend
	end if

	FB_LOCK( )
	fb_hInitConsole()
	FB_UNLOCK( )

	return res
End Function

Function fb_DylibSymbol FBCALL( library as Any ptr, symbol as FBSTRING ptr ) as Any ptr

	dim proc as Any Ptr

	if( library = NULL ) then
		library = dlopen( NULL, RTLD_LAZY )
	end if

	if( (symbol <> Null ) AndAlso ( symbol->data <> Null ) ) then
		proc = dlsym( library, symbol->data )
	end if

	return proc
End Function

Function fb_DylibSymbolByOrd FBCALL( void *library, short int symbol ) As Any Ptr

	/' Not applicable to Linux '/
	return NULL
End Function

Sub fb_DylibFree FBCALL( library as Any Ptr )

	// See above; if it's an FB lib it will restore the terminal state
	// on shutdown
	FB_LOCK( )
	fb_hExitConsole()
	FB_UNLOCK( )

	dlclose( library )

	FB_LOCK( )
	fb_hInitConsole()
	FB_UNLOCK( )
End Sub
End Extern