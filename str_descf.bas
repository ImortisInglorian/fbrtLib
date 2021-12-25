/' temp string descriptor allocation for fixed-len strings '/

#include "fb.bi"

extern "C"
function fb_StrAllocDescF FBCALL ( _str as ubyte ptr, str_size as ssize_t, result  as FBSTRING ptr ) as FBSTRING ptr

	DBG_ASSERT( result <> NULL )

	result->data = _str

	/' can't use strlen() if the size is known '/
	if ( str_size <> 0 ) then
		result->len = str_size - 1 /' less the null-term '/
	else
		if ( _str <> NULL ) then
			result->len = strlen( _str )
		else
			result->len = 0
		end if
	end if

	result->size = 0 '' didn't allocate, shouldn't free

	return result
end function
end extern