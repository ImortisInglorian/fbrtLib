/' temp string descriptor allocation for fixed-len strings '/

#include "fb.bi"

extern "C"
function fb_StrAllocTempDescF FBCALL ( _str as ubyte ptr, str_size as ssize_t ) as FBSTRING ptr
	dim as FBSTRING ptr dsc

	FB_STRLOCK()

	/' alloc a temporary descriptor '/
	dsc = fb_hStrAllocTempDesc( )

	FB_STRUNLOCK()

	if ( dsc = NULL ) then
		return @__fb_ctx.null_desc
	end if

	dsc->data = _str

	/' can't use strlen() if the size is known '/
	if ( str_size <> 0 ) then
		dsc->len = str_size - 1			/' less the null-term '/
	else
		if ( _str <> NULL ) then
			dsc->len = strlen( _str )
		else
			dsc->len = 0
		end if
	end if

	dsc->size = dsc->len

	return dsc
end function
end extern