/' unicode string assigning function '/

#include "fb.bi"

extern "C"
function fb_WstrAssign FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as FB_WCHAR ptr ) as FB_WCHAR ptr
	dim as ssize_t src_chars

	if ( dst = NULL ) then
		return dst
	end if

	if ( src = 0 ) then
		src_chars = 0
	else
		src_chars = fb_wstr_Len( src )
	end if

	/' src NULL? '/
	if ( src_chars = 0 ) then
		*dst = 0
	else
		if ( dst_chars > 0 ) then
			dst_chars -= 1						/' less the null-term '/
			/' not enough? clamp '/
			if ( dst_chars < src_chars ) then
				src_chars = dst_chars
			end if
		end if

		fb_wstr_Copy( dst, src, src_chars )
	end if

	return dst
end function
end extern