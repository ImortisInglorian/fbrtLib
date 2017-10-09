/' mid$ function '/

#include "fb.bi"

extern "C"
function fb_StrMid FBCALL ( src as FBSTRING ptr, start as ssize_t, _len as ssize_t ) as FBSTRING ptr
    dim as FBSTRING ptr dst
	dim as ssize_t src_len

	FB_STRLOCK()

    if ( (src <> NULL) and (src->data <> NULL) and (FB_STRSIZE( src ) > 0) ) then
        src_len = FB_STRSIZE( src )

        if ( (start > 0) and (start <= src_len) and (_len <> 0) ) then
			start -= 1

        	if ( _len < 0 ) then
        		_len = src_len
			end if

        	if ( start + _len > src_len ) then
        		_len = src_len - start
			end if

			/' alloc temp string '/
            dst = fb_hStrAllocTemp_NoLock( NULL, _len )
			if ( dst <> NULL ) then
				FB_MEMCPY( dst->data, src->data + start, _len )
				/' null term '/
				dst->data[_len] = 0
        	else
        		dst = @__fb_ctx.null_desc
			end if
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