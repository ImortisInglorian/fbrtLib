/' curdir$ '/

#include "fb.bi"
#ifdef HOST_WIN32
#include "windows.bi" /' for MAX_PATH '/
#endif

extern "C"
function fb_CurDir FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ubyte tmp(0 to MAX_PATH - 1)
	dim as ssize_t _len

	FB_LOCK()

	_len = fb_hGetCurrentDir( @tmp(0), MAX_PATH )

	/' alloc temp string '/
	if ( _len > 0 ) then
        dst = fb_hStrAllocTemp( NULL, _len )
		if ( dst <> NULL ) then
			memcpy( dst->data, @tmp(0), _len + 1 )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	FB_UNLOCK()

	return dst
end function
end extern