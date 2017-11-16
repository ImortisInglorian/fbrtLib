/' temp string descriptor allocation for zstring's '/

#include "fb.bi"

extern "C"
function fb_StrAllocTempDescZEx FBCALL ( _str as ubyte const ptr, _len as ssize_t ) as FBSTRING ptr
	dim as FBSTRING ptr dsc

	FB_STRLOCK()

	/' alloc a temporary descriptor '/
	dsc = fb_hStrAllocTmpDesc( )

	FB_STRUNLOCK()

	if ( dsc = NULL ) then
		return @__fb_ctx.null_desc
	end if

	dsc->data = cast(ubyte ptr, _str)
	dsc->len = _len
	dsc->size = _len

	return dsc
end function

function fb_StrAllocTempDescZ FBCALL ( _str as ubyte const ptr ) as FBSTRING ptr
	dim as ssize_t _len

	/' find the true size '/
	if ( _str <> NULL ) then
		_len = strlen( _str )
	else
		_len = 0
	end if

	return fb_StrAllocTempDescZEx( _str, _len )
end function
end extern