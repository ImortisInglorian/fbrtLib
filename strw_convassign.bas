/' ascii <-> unicode string convertion functions '/

#include "fb.bi"

extern "C"
function fb_WstrAssignFromA FBCALL (dst as FB_WCHAR ptr, dst_chars as ssize_t, src as any ptr, src_size as ssize_t ) as FB_WCHAR ptr
	dim as ubyte ptr src_ptr
	dim as ssize_t src_chars

	if ( dst <> NULL ) then
		FB_STRSETUP_FIX( src, src_size, src_ptr, src_chars )

		/' size unknown? assume it's big enough '/
		if ( dst_chars = 0 ) then
			dst_chars = src_chars
		else
			/' less the null-term '/
			dst_chars -= 1
		end if

		fb_wstr_ConvFromA( dst, dst_chars, src_ptr )
	end if

	/' delete temp? '/
	if ( src_size = -1 ) then
		fb_hStrDelTemp( cast(FBSTRING ptr, src) )
	end if

	return dst
end function

/' We'll convert wide-string to multi-byte string -- we don't know
   how big the result will be, but we can make a good guess.
   In the worst case, we'll allocate too much. '/
/' 4 bytes per char - allowing for UTF8 multi-byte strings, happens on GNU/Linux.
   On Windows there can be double-byte encodings etc. too. '/
#define getALenForWLen(wlen) ((wlen) * 4)

function fb_WstrAssignToAEx FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long, is_init as long ) as any ptr
	dim as ssize_t src_chars

	if ( dst = NULL ) then
		return dst
	end if

    if ( src <> NULL ) then
    	src_chars = fb_wstr_Len( src )
    else
    	src_chars = 0
	end if

	/' is dst var-len? '/
	if ( dst_chars = -1 ) then
		/' src NULL? '/
		if ( src_chars = 0 ) then
			if ( is_init = FB_FALSE ) then
				fb_StrDelete( cast(FBSTRING ptr, dst) )
			else
				cast(FBSTRING ptr, dst)->data = NULL
				cast(FBSTRING ptr, dst)->len = 0
				cast(FBSTRING ptr, dst)->size = 0
			end if
		else
        	/' realloc dst if needed and copy src '/
			dst_chars = getALenForWLen(src_chars)
			if ( is_init = FB_FALSE ) then
				if ( FB_STRSIZE( dst ) <> dst_chars ) then
					fb_hStrRealloc( cast(FBSTRING ptr, dst), dst_chars, FB_FALSE )
				end if
			else
				fb_hStrAlloc( cast(FBSTRING ptr, dst), dst_chars )
			end if

			dim as ssize_t writtenchars = fb_wstr_ConvToA( cast(FBSTRING ptr, dst)->data, dst_chars, src )
			fb_hStrSetLength( dst, writtenchars )
		end if
	/' fixed-len or zstring.. '/
	else
		/' src NULL? '/
		if ( src_chars = 0 ) then
			if ( fill_rem <> NULL and dst_chars > 0 ) then
				memset( dst, 0, dst_chars )
			else
				*cast(ubyte ptr, dst) = 0
			end if
		/' byte ptr? as in C, assume dst is large enough '/
		elseif ( dst_chars = 0 ) then
			dst_chars = getALenForWLen(src_chars)
			fb_wstr_ConvToA( cast(ubyte ptr, dst), dst_chars, src )
		else
			dst_chars -= 1 /' null terminator '/
			dim as ssize_t writtenchars = fb_wstr_ConvToA( cast(ubyte ptr, dst), dst_chars, src )

			/' fill remainder with null's '/
			if ( fill_rem and writtenchars < dst_chars ) then
				/' + 1 to fill behind null terminator. There is room for dst_chars + 1. '/
				memset( cast(ubyte ptr, dst) + writtenchars + 1, 0, dst_chars - writtenchars )
			end if
		end if
	end if

	return dst
end function

function fb_WstrAssignToA FBCALL (dst as any ptr,dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long ) as any ptr
	return fb_WstrAssignToAEx( dst, dst_chars, src, fill_rem, FB_FALSE )
end function

function fb_WstrAssignToA_Init FBCALL (dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long ) as any ptr
	return fb_WstrAssignToAEx( dst, dst_chars, src, fill_rem, FB_TRUE )
end function
end extern