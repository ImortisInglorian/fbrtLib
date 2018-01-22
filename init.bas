/' libfb initialization '/

#include "fb.bi"
#include "crt/locale.bi"

extern "C"

dim __fb_ctx as FB_RTLIB_CTX
dim shared __fb_is_inicnt as long = 0

/' called from fbrt0 '/
sub fb_hRtInit cdecl ( )
	/' already initialized? '/
	__fb_is_inicnt += 1
	if( __fb_is_inicnt <> 1 ) then
		return
	end if
	
	/' initialize context '/
	memset( @__fb_ctx, 0, sizeof( FB_RTLIB_CTX ) )
    
	/' os-dep initialization '/
	fb_hInit( )

#ifdef ENABLE_MT
	fb_TlsInit( )
#endif

	/''
	 * With the default "C" locale (which is just plain 7-bit ASCII),
	 * our mbstowcs() calls (from fb_wstr_ConvFromA()) fail to convert
	 * zstrings specific to the user's locale to Unicode wstrings.
	 *
	 * To fix this we must tell the CRT to use the user's locale setting,
	 * i.e. the locale given by LC_* or LANG environment variables.
	 *
	 * We should change the LC_CTYPE setting only, to affect the behaviour
	 * of the codepage <-> Unicode conversion functions, but not for
	 * example LC_NUMERIC, which would affect things like the decimal
	 * separator used by float <-> string conversion functions.
	 *
	 * Don't bother doing it under DJGPP - there we don't really support
	 * wstrings anyways, and the setlocale() reference increases .exe size.
	 '/
#ifndef HOST_DOS
	setlocale( LC_CTYPE, "" )
#endif
end sub

/' called from fbrt0 '/
sub fb_hRtExit cdecl ( )
	__fb_is_inicnt -= 1
	if( __fb_is_inicnt <> 0 ) then
		return
	end if

	/' Doing clean-up here in the rtlib's global dtor, instead of using
	   atexit().

	   FB supports global ctors/dtors, and thus FB programs can call FB
	   functions from there. Hence the rtlib/gfxlib2 initialization should
	   be the first global ctor, and the clean-up should be the last global
	   dtor. This is done by fbrt0.c. We can't rely on atexit() for this,
	   because sometimes the atexit handlers can be called before the global
	   dtors, sometimes after.

	   However, on Windows it's not safe to do certain things such as
	   waiting for a thread to finish from inside a global
	   constructor/destructor due to the loader lock. (A lock is acquired
	   to synchronize calls to DllMain() etc., so waiting for a thread from
	   inside a global destructor may cause a dead-lock, as that thread
	   needs to acquire the same lock to be able to exit.) Because of this,
	   gfxlib2 clean-up can't be done during a global dtor, at least not on
	   Windows, because its win32 backends use a background thread. So the
	   gfxlib clean-up must be done during fb_End() instead.

	   Some observations about atexit() behaviour: it depends on context,
	   e.g. whether it's called from a global ctor or global dtor or main(),
	   or whether it's a shared lib/DLL or executable,
	   and it depends on the platform (e.g. GNU/Linux vs MinGW-w64).
	   Thus it can't be used reliably. '/

	fb_FileReset( )

	/' os-dep termination '/
	fb_hEnd( 0 )

	fb_DevScrnEnd( @FB_HANDLE_SCREEN )

	/' Free main thread's TLS contexts '/
	fb_TlsFreeCtxTb( )

#ifdef ENABLE_MT
	fb_TlsExit( )
#endif

	/' If an error message was stored, print it now, after the console was
	   cleaned up. At least the DOS gfxlib clears the console on exit,
	   thus any error messages must be printed after that or they would
	   not be visible. '/
	if( __fb_ctx.errmsg <> NULL ) then
		fputs( __fb_ctx.errmsg, stderr )
	end if
end sub

/' called by FB program '/
sub fb_Init FBCALL( argc as long, argv as ubyte ptr ptr, lang as long )
	__fb_ctx.argc = argc
	__fb_ctx.argv = argv
	__fb_ctx.lang = lang
end sub

/' called by FB program,
   or fb_Die() in case of assert() failure or runtime error '/
sub fb_End FBCALL ( errlevel as long )
	if( __fb_ctx.exit_gfxlib2 <> NULL ) then
		__fb_ctx.exit_gfxlib2( )
	end if

	end( errlevel )
end sub
end extern
