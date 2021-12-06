/' unicode to ascii string convertion function '/

#include "fb.bi"

extern "C"
/' dst_chars == room in dst buffer without null terminator. Thus, the dst buffer
   must be at least dst_chars+1 bytes.
   src must be null-terminated.
   result = number of chars written, excluding null terminator that is always written '/
function fb_wstr_ConvToA( dst as ubyte ptr, dst_chars as ssize_t, src as const FB_WCHAR ptr ) as ssize_t
	if (src = NULL) then
		*dst = 0
		return 0
	end if

#if defined(HOST_DOS)
	dim as ssize_t chars = strlen(src)
	if (chars > dst_chars) then
		chars = dst_chars
	end if

	memcpy(dst, src, chars + 1)
	return chars
#else
	/' plus the null-term '/
	dim as ssize_t chars = wcstombs(dst, cast(FB_WCHAR ptr, src), dst_chars + 1)

	/' worked? '/
	if (chars >= 0) then
		/' a null terminator won't be added if there was not
		   enough space, so do it manually (this will cut off the last
		   char, but what can you do) '/
		if (chars = (dst_chars + 1)) then
			dst[dst_chars] = asc( !"\000" )
			return dst_chars - 1
		end if
		return chars
	end if

	/' wcstombs() failed; translate at least ASCII chars
	   and write out '?' for the others '/
	dim as ubyte ptr origdst = dst
	dim as ubyte ptr dstlimit = dst + dst_chars
	while (dst < dstlimit)
#if defined(HOST_WIN32)
		dim as UTF_16 c = *src
		src += 1
		if (c = 0) then
			exit while
		end if
		if (c > 127) then
			if (c >= UTF16_SUR_HIGH_START andalso c <= UTF16_SUR_HIGH_END) then
				src += 1
			end if
			c = asc("?")
		end if
#else
		dim as UTF_32 c = *src 
		src += 1		 
		if (c = 0) then
			exit while
		end if
		if (c > 127) then
			c = asc("?")
		end if
#endif
		*dst = c
		dst += 1
	wend
	*dst = asc( !"\000" )
	return dst - origdst
#endif
end function

function fb_WstrToStr FBCALL ( src as const FB_WCHAR ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t chars

    if ( src = NULL ) then
    	return @__fb_ctx.null_desc
	end if

#if defined(HOST_DOS)
	/' on DOS, wcstombs() simply calls memcpy() and won't compute
       length  see fb_unicode.h '/
	chars = fb_wstr_Len( src )
#else
	chars = wcstombs( NULL, cast(FB_WCHAR ptr, src), 0 )
#endif
    if ( chars = 0 ) then
    	return @__fb_ctx.null_desc
	end if

    dst = fb_hStrAllocTemp( NULL, chars )
	if ( dst = NULL ) then
		return @__fb_ctx.null_desc
	end if

	fb_wstr_ConvToA( dst->data, chars, src )

	return dst
end function
end extern