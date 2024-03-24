/' 
	run-time optimization for:

		dim shared m as string
		sub proc( byref s as string, byref t as string )
			'' these are optimized to fb_StrConcatByref() 
			m += s
			s += t
		end sub

		dim as string a, b
		proc( m, a )
		proc( a, a )
		proc( a, b )

	it can't be determined at compile time within proc() if the strings passed
	to proc() are the same strings.  Might be able to use fb_StrConcatAssign() 
	but only if it is known that the strings are different.  Otherwise the
	contents of the string could be destroyed before the are copied.  If the
	strings are the same, then extend the buffer and copy the first part of the
	string to the second half.

	We should only get here if the left hand side variable was an FBSTRING type
	and we should expect a string descriptor.
'/

#include "fb.bi"

extern "C"
function fb_StrConcatByref FBCALL _
	( _
		byval dst as any ptr, _
		byval dst_size as ssize_t, _
		byval src as any ptr, _
		byval src_size as ssize_t, _
		byval fillrem as long _
	) as any ptr

	dim as ubyte ptr dst_ptr = any
	dim as const ubyte ptr src_ptr = any
	dim as ssize_t dst_len = any, src_len = any

	/' dst should always be var-len string '/
	DBG_ASSERT( dst_size = FB_STRSIZEVARLEN )

	/' dst '/
	FB_STRSETUP_FIX( dst, dst_size, dst_ptr, dst_len )

	/' src '/
	FB_STRSETUP_FIX( src, src_size, src_ptr, src_len )

	/' Are dst & src same same data? '/
	if( dst = src orelse dst_ptr = src_ptr ) then
		dim as FBSTRING ptr str_ = dst

		FB_STRLOCK()
		
		if( fb_hStrRealloc( str_, dst_len + src_len, FB_TRUE ) ) then
			/' recalculate dst '/
			FB_STRSETUP_FIX( str_, dst_size, dst_ptr, dst_len )

			/' copy start of dst to second half '/
			FB_MEMCPYX( dst_ptr + dst_len, dst, dst_len )

			fb_hStrSetLength( str_, dst_len + dst_len )

			str_->data[dst_len + dst_len] = asc( !"\000" ) '' NUL CHAR
		end if

		/' delete temps? '/
		if( dst_size = FB_STRSIZEVARLEN ) then
			fb_hStrDelTemp_NoLock( cast( FBSTRING ptr, dst ) )
		end if
		if( src_size = FB_STRSIZEVARLEN ) then
			fb_hStrDelTemp_NoLock( cast( FBSTRING ptr, src ) )
		end if

		FB_STRUNLOCK()

		return dst
	end if

	return fb_StrConcatAssign( dst, dst_size, src, src_size, fillrem )
end function
end extern
