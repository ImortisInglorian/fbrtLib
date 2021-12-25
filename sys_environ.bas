/' environ$ function and setenviron stmt '/

#include "fb.bi"
#include "destruct_string.bi"
#include "crt/stdlib.bi"

extern "C"
function fb_GetEnviron FBCALL ( varname as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ubyte ptr tmp
	dim as ssize_t _len

	DBG_ASSERT( result <> NULL )

	if ( (varname <> NULL) andalso (varname->data <> NULL) ) then
		tmp = getenv( varname->data )
		if ( tmp <> NULL ) then
			_len = strlen( tmp )
			if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
				fb_hStrCopy( dst.data, tmp, _len )
			end if
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function

function fb_SetEnviron FBCALL ( _str as FBSTRING ptr ) as long
	dim as long res = 0

	if ( (_str <> NULL) andalso (_str->data <> NULL) ) then
		res = _putenv( _str->data )
	end if

	return res
end function
end extern