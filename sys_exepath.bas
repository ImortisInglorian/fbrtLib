/' exepath$ '/

#include "fb.bi"
#include "destruct_string.bi"
#ifdef HOST_WIN32
	#include "windows.bi"
#endif

extern "C"
function fb_ExePath FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ubyte ptr p
	dim as ubyte tmp(0 to MAX_PATH)
	dim as ssize_t _len

	DBG_ASSERT( result <> NULL )

	p = fb_hGetExePath( @tmp(0), MAX_PATH )

	if ( p <> NULL ) then
		_len = strlen( @tmp(0) )
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			fb_hStrCopy( dst.data, @tmp(0), _len )
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern