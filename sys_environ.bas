/' environ$ function and setenviron stmt '/

#include "fb.bi"
#include "crt/stdlib.bi"

extern "C"
function fb_GetEnviron FBCALL ( varname as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ubyte ptr tmp
	dim as ssize_t _len

	if ( (varname <> NULL) and (varname->data <> NULL) ) then
		tmp = getenv( varname->data )
	else
		tmp = NULL
	end if

	FB_STRLOCK()

	if ( tmp <> NULL ) then
        _len = strlen( tmp )
        dst = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( dst <> NULL ) then
			fb_hStrCopy( dst->data, tmp, _len )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( varname )

	FB_STRUNLOCK()

	return dst
end function

function fb_SetEnviron FBCALL ( _str as FBSTRING ptr ) as long
	dim as long res = 0

	if ( (_str <> NULL) and (_str->data <> NULL) ) then
		res = _putenv( _str->data )
	end if

	/' del if temp '/
	fb_hStrDelTemp( _str )

	return res
end function
end extern