/' ascii to unicode string convertion function '/

#include "fb.bi"

extern "C"
/' dst_chars == room in dst buffer without null terminator. Thus, the dst buffer
   must be at least (dst_chars + 1) * sizeof(FB_WCHAR).
   src must be null-terminated.
   result = number of chars written, excluding null terminator that is always written '/
function fb_wstr_ConvFromA( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as const ubyte ptr ) as ssize_t
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
	/' plus the null-term (note: "n" in chars, not bytes!) '/
	dim as ssize_t chars = mbstowcs(dst, src, dst_chars + 1)

	/' worked? '/
	if (chars >= 0) then
		/' a null terminator won't be added if there was not
		   enough space, so do it manually (this will cut off the last
		   char, but what can you do) '/
		if (chars = (dst_chars + 1)) then
			dst[dst_chars] = 0
			return dst_chars - 1
		end if
		return chars
	end if

	/' mbstowcs() failed; translate at least ASCII chars
	   and write out '?' for the others '/
	dim as FB_WCHAR ptr origdst = dst
	dim as FB_WCHAR ptr dstlimit = dst + dst_chars
	while (dst < dstlimit)
		dim as ubyte c = *src + 1
		if (c = 0) then
			exit while
		end if
		if (c > 127) then
			c = 63
		end if
		*dst += 1
		*dst = c
	wend
	*dst = 0
	return dst - origdst
#endif
end function

function fb_StrToWstr FBCALL ( src as const ubyte ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t chars

    if ( src = NULL ) then
    	return NULL
	end if

	chars = strlen( src )
    if ( chars = 0 ) then
    	return NULL
	end if

    dst = fb_wstr_AllocTemp( chars )
	if ( dst = NULL ) then
		return NULL
	end if

	fb_wstr_ConvFromA( dst, chars, src )

	return dst
end function
end extern