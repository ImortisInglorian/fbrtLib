/' string concat and assign (s = s + expr) function '/

#include "fb.bi"

extern "C"
function fb_WstrConcatAssign FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim as ssize_t src_len, dst_len

	/' NULL? '/
	if ( (dst = NULL) or (src = NULL) ) then
		return dst
	end if

	src_len = fb_wstr_Len( src )
	if ( src_len = 0 ) then
		return dst
	end if

	dst_len = fb_wstr_Len( dst )

	/' don't check ptr's '/
	if ( dst_chars > 0 ) then
		dst_chars -= 1							/' less the null-term '/

		if ( src_len > dst_chars - dst_len ) then
			src_len = dst_chars - dst_len
		end if
	end if

	/' copy the null-term too '/
	fb_wstr_Move( @dst[dst_len], src, src_len + 1 )

	return dst
end function
end extern