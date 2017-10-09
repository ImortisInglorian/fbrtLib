/' mid$ statement '/

#include "fb.bi"

extern "C"
sub fb_StrAssignMid FBCALL ( dst as FBSTRING ptr, start as ssize_t, _len as ssize_t, src as FBSTRING ptr )
	dim as ssize_t src_len, dst_len

	FB_STRLOCK()

    if ( (dst = NULL) or (dst->data = NULL) or (FB_STRSIZE( dst ) = 0) ) then
    	fb_hStrDelTemp_NoLock( src )
    	fb_hStrDelTemp_NoLock( dst )
    	FB_STRUNLOCK()
    	exit sub
    end if

    if ( (src = NULL) or (src->data = NULL) or (FB_STRSIZE( src ) = 0) ) then
        fb_hStrDelTemp_NoLock( src )
    	fb_hStrDelTemp_NoLock( dst )
    	FB_STRUNLOCK()
    	exit sub 
    end if

	src_len = FB_STRSIZE( src )
	dst_len = FB_STRSIZE( dst )

	if ( (start > 0) and (start <= dst_len) and (_len <> 0) ) then
		start -= 1

		if ( (_len < 0) or (_len > src_len) ) then
			_len = src_len
		end if

        if ( start + _len > dst_len ) then
        	_len = (dst_len - start)
		end if

		memcpy( dst->data + start, src->data, _len )
    end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )
    fb_hStrDelTemp_NoLock( dst )

   	FB_STRUNLOCK()
end sub
end extern