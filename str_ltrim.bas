/' ltrim$ function '/

#include "fb.bi"

extern "C"
function fb_LTRIM FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t _len
	dim as ubyte ptr src_ptr = NULL

	if ( src = NULL ) then
		return @__fb_ctx.null_desc
	end if

	FB_STRLOCK()

	if ( src->data <> NULL ) then
		src_ptr = fb_hStrSkipChar( src->data, FB_STRSIZE( src ), 32 )
		_len = FB_STRSIZE( src ) - cast(ssize_t, (src_ptr - src->data))
	else
		_len = 0
	end if

	if ( _len > 0 ) then
		/' alloc temp string '/
        dst = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( dst <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst->data, src_ptr, _len )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if
	
	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )

	FB_STRUNLOCK()

	return dst
end function
end extern