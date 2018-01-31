/' exepath$ '/

#include "fb.bi"
#ifdef HOST_WIN32
	#include "windows.bi"
#endif

extern "C"
function fb_ExePath FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ubyte ptr p
	dim as ubyte tmp(0 to MAX_PATH)
	dim as ssize_t _len

	p = fb_hGetExePath( @tmp(0), MAX_PATH )

	if ( p <> NULL ) then
		/' alloc temp string '/
        _len = strlen( @tmp(0) )
        dst = fb_hStrAllocTemp( NULL, _len )
		if ( dst <> NULL ) then
			fb_hStrCopy( dst->data, @tmp(0), _len )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function
end extern