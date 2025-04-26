/' ascii to unicode string convertion function '/

#include "fb.bi"

extern "C"
private function fb_wstr_ConvFromA_nomultibyte( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as const ubyte ptr ) as ssize_t

	/' mbstowcs() must have failed; translate at least ASCII chars
	   and write out '?' for the others '/
	dim as FB_WCHAR ptr origdst = dst
	dim as FB_WCHAR ptr dstlimit = dst + dst_chars
	while (dst < dstlimit)
		dim as ubyte c = *src 
		src += 1
		if (c = 0) then
			exit while
		end if
		if (c > 127) then
			c = asc("?")
		end if
		*dst = c
		*dst += 1
	wend
	*dst = asc(!"\000") '' NUL CHAR
	return dst - origdst
end function


/' dst_chars == room in dst buffer without null terminator. Thus, the dst buffer
   must be at least (dst_chars + 1) * sizeof(FB_WCHAR).
   src must be null-terminated.
   result = number of chars written, excluding null terminator that is always written '/
function fb_wstr_ConvFromA( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as const ubyte ptr ) as ssize_t
	if (src = NULL) then
		*dst = asc(!"\000") '' NUL CHAR
		return 0
	end if

#if defined(DISABLE_WCHAR)
	dim as ssize_t chars = strlen(src)
	if (chars > dst_chars) then
		chars = dst_chars
	end if

	memcpy(dst, src, chars + 1)

	/* ensure that the null terminator is written, string may have been truncated */
	dst[chars] = asc(!"\000") '' NUL CHAR

	return chars
#else
	/' plus the null-term (note: "n" in chars, not bytes!) '/
	dim as ssize_t chars = mbstowcs(dst, cast(ubyte ptr, src), dst_chars + 1)

	/' worked? '/
	if (chars >= 0) then
		/' a null terminator won't be added if there was not
		   enough space, so do it manually (this will cut off the last
		   char, but what can you do) '/
		if (chars = (dst_chars + 1)) then
			dst[dst_chars] = asc(!"\000") '' NUL CHAR
			return dst_chars - 1
		end if
		return chars
	end if

	/' mbstowcs() failed?; translate at least ASCII chars
	'' and write out '?' for the others
	'/
	return fb_wstr_ConvFromA_nomultibyte( dst, dst_chars, src )

#endif
end function

function fb_StrToWstr FBCALL ( src as const ubyte ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst
	dim as ssize_t chars

	if( src = NULL ) then
		return NULL
	end if

#if defined( __FB_DOS__ )
	/' on DOS, mbstowcs() simply calls memcpy() and won't compute
	length  see fb_unicode.h '/
	chars = strlen( src )
#else
	chars = mbstowcs( NULL, cast(ubyte ptr, src), 0 )

	/' invalid multibyte characters? get the plain old NUL terminated 
	'' string length and allocate a buffer for at least the ASCII chars 
	'/
	if( chars < 0 ) then
		chars = strlen( src )
		dst = fb_wstr_AllocTemp( chars )
		if( dst = NULL ) then
			return NULL
		end if
		/' don't bother calling fb_wstr_ConvFromA() it will just call the trivial conversion anyway '/
		fb_wstr_ConvFromA_nomultibyte( dst, chars, src )
		return dst
	end if

#endif
	if( chars = 0 ) then
		return NULL
	end if

	dst = fb_wstr_AllocTemp( chars )
	if( dst = NULL ) then
		return NULL
	end if

	fb_wstr_ConvFromA( dst, chars, src )

	return dst

end function
end extern