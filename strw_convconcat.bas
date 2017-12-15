/' wstring concatenation + convertion functions '/

#include "fb.bi"

extern "C"
function fb_WstrConcatWA FBCALL ( str1 as FB_WCHAR const ptr, str2 as any const ptr, str2_size as ssize_t ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t str1_len, str2_len
	dim as ubyte ptr str2_ptr

	if ( str1 <> NULL ) then
		str1_len = fb_wstr_Len( str1 )
	else
		str1_len = 0
	end if

	FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

	/' NULL? '/
	if ( str1_len + str2_len = 0 ) then
		dst = NULL
	else
		/' alloc temp string '/
    	dst = fb_wstr_AllocTemp( str1_len + str2_len )

		/' do the concatenation '/
    	fb_wstr_Move( dst, str1, str1_len )
    	fb_wstr_ConvFromA( @dst[str1_len], str2_len, str2_ptr )
    end if

	/' delete temp? '/
	if ( str2_size = -1 ) then
		fb_hStrDelTemp( cast(FBSTRING ptr, str2) )
	end if

	return dst
end function

function fb_WstrConcatAW FBCALL ( str1 as any const ptr, str1_size as ssize_t, str2 as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t str1_len, str2_len
	dim as ubyte ptr str1_ptr

	FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )

	if ( str2 <> NULL ) then
		str2_len = fb_wstr_Len( str2 )
	else
		str2_len = 0
	end if

	/' NULL? '/
	if ( str1_len + str2_len = 0 ) then
		dst = NULL
	else
		/' alloc temp string '/
    	dst = fb_wstr_AllocTemp( str1_len + str2_len )

		/' do the concatenation '/
    	fb_wstr_ConvFromA( dst, str1_len, str1_ptr )
    	if ( str2_len > 0 ) then
    		fb_wstr_Move( @dst[str1_len], str2, str2_len + 1 )
		end if
    end if

	/' delete temp? '/
	if ( str1_size = -1 ) then
		fb_hStrDelTemp( cast(FBSTRING ptr, str1) )
	end if

	return dst
end function
end extern