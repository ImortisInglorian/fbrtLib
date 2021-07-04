/' midw$ statement '/

#include "fb.bi"
extern "C"
sub fb_WstrAssignMid FBCALL ( dst as FB_WCHAR ptr, dst_len as ssize_t, start as ssize_t, _len as ssize_t, src as const FB_WCHAR ptr )
	dim as ssize_t src_len

    if ( (dst = NULL) or (src = NULL) ) then
    	exit sub
	end if

    src_len = fb_wstr_Len( src )
    if ( src_len = 0 ) then
    	exit sub
	end if

    if ( dst_len = 0 ) then
    	/' it's a pointer, assume it's large enough '/
    	dst_len = fb_wstr_Len( dst ) + src_len
    end if

    if ( (start > 0) and (start <= dst_len) ) then
		start -= 1

        if ( (_len < 1) or (_len > src_len) ) then
			_len = src_len
		end if

        if ( start + _len > dst_len ) then
        	_len = (dst_len - start) - 1
		end if

		/' without the null-term '/
		fb_wstr_Move( @dst[start], src, _len )
    end if
end sub
end extern