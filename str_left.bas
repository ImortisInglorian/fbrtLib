/' left$ function '/

#include "fb.bi"

extern "C"
function fb_LEFT FBCALL ( src as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t _len, src_len

	if ( src = NULL ) then
		return @__fb_ctx.null_desc
	end if

	FB_STRLOCK()

	src_len = FB_STRSIZE( src )
	if ( (src->data <> NULL) and (chars > 0) and (src_len > 0) ) then
		if ( chars > src_len ) then
			_len = src_len
		else
			_len = chars
		end if

		/' alloc temp string '/
        dst = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( dst <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst->data, src->data, _len )
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