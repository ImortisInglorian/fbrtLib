/' swap for wstrings '/

#include "fb.bi"

extern "C"
sub fb_WstrSwap FBCALL ( str1 as FB_WCHAR ptr, size1 as ssize_t, str2 as FB_WCHAR ptr, size2 as ssize_t )
	if ( (str1 = NULL) or (str2 = NULL) ) then
		exit sub
	end if

	/' Retrieve lengths '/
	dim as ssize_t len1, len2

	/' user-allocated wstring? '/
	if ( size1 <= 0 ) then
		len1 = fb_wstr_Len( str1 )
	else
		len1 = size1 - 1
	end if

	if ( size2 <= 0 ) then
		len2 = fb_wstr_Len( str2 )
	else
		len2 = size2 - 1
	end if

	/' Same length? Only need to do an fb_MemSwap() '/
	if ( len1 = len2 ) then
		if ( len1 > 0 ) then
			fb_MemSwap( cast(ubyte ptr, str1), cast(ubyte ptr, str2), len1 * sizeof( FB_WCHAR ) )
			/' null terminators don't need to change '/
		end if
		exit sub
	end if

	/' Make str1/str2 be the smaller/larger string respectively '/
	if ( len1 > len2 ) then
		scope
			dim as FB_WCHAR ptr _str = str1
			str1 = str2
			str2 = _str
		end scope

		scope
			dim as ssize_t _len = len1
			len1 = len2
			len2 = _len
		end scope

		scope
			dim as ssize_t size = size1
			size1 = size2
			size2 = size
		end scope
	end if

	/' MemSwap as much as possible (i.e. the smaller length) '/
	if ( len1 > 0 ) then
		fb_MemSwap( cast(ubyte ptr, str1), cast(ubyte ptr, str2), len1 * sizeof( FB_WCHAR ) )
	end if

	/' and copy over the remainder from larger to smaller, unless it's
	   a fixed-size wstring that doesn't have enough room left '/
	if ( (size1 > 0) and (len2 >= size1) ) then
		len2 = len1
	elseif ( len2 > len1 ) then
		fb_wstr_Move( (str1 + len1), (str2 + len1), len2 - len1 )
	end if

	/' set null terminators '/
	str1[len2] = 0
	str2[len1] = 0
end sub
end extern