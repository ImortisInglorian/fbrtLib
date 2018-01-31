/' ascii to UTF conversion '/

#include "fb.bi"

extern "C"
private function hToUTF8( src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
	if ( chars > 0 ) then
		if ( dst = NULL ) then
			dst = malloc( chars * 2 )
			if ( dst = NULL ) then
				return NULL
			end if
		end if

		fb_hCharToUTF8( src, chars, dst, bytes )
	else
		*bytes = 0
	end if

	return dst
end function

private function hToUTF16( src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
	dim as UTF_16 ptr p

	/' !!!FIXME!!! only litle-endian supported '/

	*bytes = chars * sizeof( UTF_16 )

	if ( chars > 0 ) then
		if ( dst = NULL ) then
			dst = malloc( chars * sizeof( UTF_16 ) )
			if ( dst = NULL ) then
				return NULL
			end if
		end if
	end if

	p = cast(UTF_16 ptr, dst)
	while( chars > 0 )
		p += 1
		*p = cast(ubyte, *src + 1)
		chars -= 1
	wend

	return dst
end function

private function hToUTF32( src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
	dim as UTF_32 ptr p

	/' !!!FIXME!!! only litle-endian supported '/

	*bytes = chars * sizeof( UTF_32 )

	if ( chars > 0 ) then
		if ( dst = NULL ) then
			dst = malloc( chars * sizeof( UTF_32 ) )
			if ( dst = NULL ) then
				return NULL
			end if
		end if
	end if

	p = cast(UTF_32 ptr,dst)
	while( chars > 0 )
		p += 1
		*p = cast(ubyte, *src + 1)
		chars -= 1
	wend

	return dst
end function

function fb_CharToUTF( encod as FB_FILE_ENCOD, src as ubyte const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
	select case ( encod )
		case FB_FILE_ENCOD_UTF8:
			return hToUTF8( src, chars, dst, bytes )
		case FB_FILE_ENCOD_UTF16:
			return hToUTF16( src, chars, dst, bytes )
		case FB_FILE_ENCOD_UTF32:
			return hToUTF32( src, chars, dst, bytes )
		case else:
			return NULL
	end select
end function
end extern