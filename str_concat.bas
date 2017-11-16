/' string concatenation function '/

#include "fb.bi"

extern "C"
sub fb_hStrConcat ( dst as ubyte ptr, str1 as ubyte const ptr, len1 as ssize_t, str2 as ubyte const ptr, len2 as ssize_t )
   dst = cast(ubyte ptr, FB_MEMCPYX( dst, str1, len1 ))
   dst = cast(ubyte ptr, FB_MEMCPYX( dst, str2, len2 ))
	*dst = 0
end sub

function fb_StrConcat FBCALL ( dst as FBSTRING ptr, str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as FBSTRING ptr
	dim as ubyte ptr str1_ptr, str2_ptr
	dim as ssize_t str1_len, str2_len

	FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )

	FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

	/' NULL? '/
	if ( str1_len + str2_len = 0 ) then
		fb_StrDelete( dst )
	else
		/' alloc temp string '/
		dst = fb_hStrAllocTemp( dst, str1_len + str2_len )
		DBG_ASSERT( dst )

		/' do the concatenation '/
		fb_hStrConcat( dst->data, str1_ptr, str1_len, str2_ptr, str2_len )
	end if

	FB_STRLOCK()

	/' delete temps? '/
	if ( str1_size = -1 ) then
		fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, str1) )
	end if
	if ( str2_size = -1 ) then
		fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, str2) )
	end if
	FB_STRUNLOCK()

	return dst
end function
end extern