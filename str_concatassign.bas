/' string concat and assigning (s = s + expr) function '/

#include "fb.bi"

extern "C"
function fb_StrConcatAssign FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr, src_size as ssize_t, fillrem as long ) as any ptr
	dim dstr as FBSTRING ptr
	dim src_ptr as ubyte ptr
	dim as ssize_t src_len, dst_len

	if ( dst = NULL ) then
		/' delete temp? '/
		if ( src_size = FB_STRSIZEVARLEN ) then
			fb_hStrDelTemp( cast(FBSTRING ptr, src) )
		end if
		return dst
	end if

	/' src '/
	FB_STRSETUP_FIX( src, src_size, src_ptr, src_len )

	/' not NULL? '/
	if ( src_len > 0 ) then
		/' is dst var-len? '/
		if ( dst_size = FB_STRSIZEVARLEN ) then
			dstr = cast(FBSTRING ptr, dst)
			dst_len = FB_STRSIZE( dst )

			fb_hStrRealloc( dstr, dst_len + src_len, FB_TRUE )

			fb_hStrCopy( @dstr->data[dst_len], src_ptr, src_len )
		elseif( dst_size and FB_STRISFIXED) then
			/' do nothing, can't concat to STRING*N
			because it is padded with spaces '/
		else
			dst_len = strlen( cast(ubyte ptr, dst) )

			/' don't check byte ptr's '/
			if ( dst_size > 0 ) then
				/' less the null-term '/
				dst_size -= 1

				if ( src_len > dst_size - dst_len ) then
					src_len = dst_size - dst_len
				end if
			end if

			fb_hStrCopy( @((cast(ubyte ptr, dst))[dst_len]), src_ptr, src_len )

			/' don't check byte ptr's '/
			if ( (fillrem <> 0) and (dst_size > 0) ) then
				/' fill reminder with null's '/
				dst_size -= (dst_len + src_len)
				if ( dst_size > 0 ) then
					memset( @((cast(ubyte ptr, dst))[dst_len + src_len]), 0, dst_size )
				end if
			end if
		end if
	end if

	/' delete temp? '/
	if ( src_size = FB_STRSIZEVARLEN ) then
		fb_hStrDelTemp( cast(FBSTRING ptr, src) )
	end if
	return dst
end function
end extern