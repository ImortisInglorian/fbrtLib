/' legacy: temp string descriptor allocation for var-len strings '/

#include "fb.bi"

extern "C"
function fb_StrAllocTempDescV FBCALL ( _str as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dsc

	FB_STRLOCK()

	/' alloc a temporary descriptor '/
	dsc = fb_hStrAllocTempDesc( )

	FB_STRUNLOCK()

	if ( dsc = NULL ) then
		return @__fb_ctx.null_desc
	end if

	dsc->data = _str->data
	dsc->len  = FB_STRSIZE( _str )
	dsc->size = _str->size

	return dsc
end function
end extern