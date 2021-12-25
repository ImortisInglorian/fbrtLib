/' curdir$ '/

#include "fb.bi"
#include "destruct_string.bi"
#ifdef HOST_WIN32
#include "windows.bi" /' for MAX_PATH '/
#endif

extern "C"
function fb_CurDir FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ubyte tmp(0 to MAX_PATH - 1)
	dim as ssize_t _len

	DBG_ASSERT( result <> NULL )

	_len = fb_hGetCurrentDir( @tmp(0), MAX_PATH )

	/' alloc string '/
	if ( _len > 0 AndAlso ( fb_hStrAlloc( @dst, _len ) <> NULL ) ) then
		memcpy( dst.data, @tmp(0), _len + 1 )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern