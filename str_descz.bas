/' temp string descriptor allocation for zstring's '/

#include "fb.bi"

extern "C"
function fb_StrAllocDescZEx FBCALL ( _str as const ubyte ptr, _len as ssize_t, result as FBSTRING ptr ) as FBSTRING ptr
	DBG_ASSERT( result <> NULL )

	result->data = cast(ubyte ptr, _str)
	result->len = _len
	result->size = 0

	return result
end function

function fb_StrAllocDescZ FBCALL ( _str as const ubyte ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as ssize_t _len

	DBG_ASSERT( result <> NULL )

	/' find the true size '/
	if ( _str <> NULL ) then
		_len = strlen( _str )
	else
		_len = 0
	end if

	return fb_StrAllocDescZEx( _str, _len, result )
end function
end extern