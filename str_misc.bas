/' misc string routines '/

#include "fb.bi"

extern "C"
function fb_SPACE FBCALL ( _len as ssize_t ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	if ( _len > 0 ) then
		/' alloc temp string '/
        dst = fb_hStrAllocTemp( NULL, _len )
		if ( dst <> NULL ) then
			/' fill it '/
			memset( dst->data, 32, _len )

			/' null char '/
			dst->data[_len] = 0
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function
end extern