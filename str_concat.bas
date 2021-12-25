/' string concatenation function '/

#include "fb.bi"
#include "destruct_string.bi"

sub fb_hStrConcat ( dst as ubyte ptr, str1 as const ubyte ptr, len1 as ssize_t, str2 as const ubyte ptr, len2 as ssize_t )
	dst = cast(ubyte ptr, FB_MEMCPYX( dst, str1, len1 ))
	dst = cast(ubyte ptr, FB_MEMCPYX( dst, str2, len2 ))
	*dst = 0
end sub

extern "C"
function fb_StrConcat FBCALL ( dst as FBSTRING ptr, str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as FBSTRING ptr
	dim as ubyte ptr str1_ptr, str2_ptr
	dim as ssize_t str1_len, str2_len

	FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )

	FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

	/' NULL? '/
	if ( str1_len + str2_len = 0 ) then
		fb_StrDelete( dst )
	else
		dim as destructable_string tmp_str
		/' alloc temp string '/
		fb_hStrAlloc( @tmp_str, str1_len + str2_len )
		DBG_ASSERT( tmp_str.data )

		/' do the concatenation '/
		fb_hStrConcat( tmp_str.data, str1_ptr, str1_len, str2_ptr, str2_len )
		fb_StrSwapDesc( dst, @tmp_str)
	end if

	return dst
end function
end extern