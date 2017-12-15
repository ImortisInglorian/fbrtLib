/' wstring concatenation function '/

#include "fb.bi"

extern "C"
function fb_WstrConcat FBCALL ( str1 as FB_WCHAR const ptr, str2 as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, d
	dim as ssize_t str1_len, str2_len

	if ( str1 <> NULL ) then
		str1_len = fb_wstr_Len( str1 )
	else
		str1_len = 0
	end if

	if ( str2 <> NULL ) then
		str2_len = fb_wstr_Len( str2 )
	else
		str2_len = 0
	end if

	/' NULL? '/
	if ( str1_len + str2_len = 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( str1_len + str2_len )

	/' do the concatenation '/
    d = fb_wstr_Move( dst, str1, str1_len )
    d = fb_wstr_Move( d, str2, str2_len )
    *d = 0

	return dst
end function
end extern