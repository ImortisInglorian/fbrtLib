/' legacy: temp string descriptor allocation for var-len strings '/

#include "fb.bi"

extern "C"
function fb_StrAllocTempDescV FBCALL ( _str as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	DBG_ASSERT( result <> NULL )

	result->data = _str->data
	result->len  = FB_STRSIZE( _str )
	result->size = 0 '' we didn't allocate, we shouldn't free

	return result
end function
end extern