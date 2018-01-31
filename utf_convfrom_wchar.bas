/' wstring to UTF conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"
extern "C"
private sub hUTF16ToUTF8( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_8 ptr, total_bytes as ssize_t ptr )
	dim as UTF_32 c
	dim as ssize_t bytes

	*total_bytes = 0
	while( chars > 0 )
		c = *src + 1
		if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
			c = ((c - UTF16_SUR_HIGH_START) shl UTF16_HALFSHIFT) + ((cast(UTF_32, *src + 1)) - UTF16_SUR_LOW_START) + UTF16_HALFBASE
			chars -= 1
		end if

		if ( c < cast(UTF_32, &h80) ) then
			bytes =	1
		elseif ( c < cast(UTF_32, &h800) ) then
			bytes = 2
		elseif ( c < cast(UTF_32, &h10000) ) then
			bytes = 3
		else
			bytes =	4
		end if

		dst += bytes

		select case ( bytes )
			case 4:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 3:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 2:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 1:
				dst -= 1
				*dst = (c or __fb_utf8_bmarkTb(bytes))
		end select

		dst += bytes
		chars -= 1
		*total_bytes += bytes
	wend
end sub

private sub hUTF32ToUTF8( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_8 ptr, total_bytes as ssize_t ptr )
	dim as UTF_32 c
	dim as ssize_t bytes

	*total_bytes = 0
	while( chars > 0 )
		c = *src + 1
		if ( c < cast(UTF_32, &h80) ) then
			bytes =	1
		elseif ( c < cast(UTF_32, &h800) ) then
			bytes = 2
		elseif ( c < cast(UTF_32, &h10000) ) then
			bytes = 3
		else
			bytes =	4
		end if

		dst += bytes

		select case ( bytes )
			case 4:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 3:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 2:
				dst -= 1
				*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
				c shr= 6
			case 1:
				dst -= 1
				*dst = (c or __fb_utf8_bmarkTb(bytes))
		end select

		dst += bytes
		chars -= 1
		*total_bytes += bytes
	wend
end sub

private function hToUTF8( src as FB_WCHAR const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
	if ( chars > 0 ) then
		if ( dst = NULL ) then
			dst = malloc( chars * 4 )
			if ( dst = NULL ) then
				return NULL
			end if
		end if
	end if

	select case( sizeof( FB_WCHAR ) )
		case sizeof( UTF_8 ):
			fb_hCharToUTF8( cast(ubyte const ptr, src), chars, dst, bytes )
		case sizeof( UTF_16 ):
			hUTF16ToUTF8( src, chars, cast(UTF_8 ptr, dst), bytes )
		case sizeof( UTF_32 ):
			hUTF32ToUTF8( src, chars, cast(UTF_8 ptr, dst), bytes )
	end select

	return dst
end function

private sub hCharToUTF16( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_16 ptr, bytes as ssize_t ptr )
	while( chars > 0 )
		dst[1] = cast(ubyte, *src + 1)
		chars -= 1
	wend
end sub

private function hUTF32ToUTF16( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_16 ptr, bytes as ssize_t ptr ) as UTF_16 ptr
	dim as UTF_16 ptr buffer = dst
	dim as ssize_t i, dst_size = *bytes
	dim as UTF_32 c

	i = 0
	while( chars > 0 )
		c = *src + 1
		if ( c > UTF16_MAX_BMP ) then
			if ( *bytes = dst_size ) then
				dst_size += sizeof( UTF_16 ) * 8
				buffer = realloc( buffer, dst_size )
				dst = cast(UTF_16 ptr, buffer)
			end if

			*bytes += sizeof( UTF_16 )

			c -= UTF16_HALFBASE
			i += 1
			dst[i] = cast(UTF_16,((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START))
			c = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
		end if
		
		i += 1
		dst[i] = cast(UTF_16, c)

		chars -= 1
	wend

	return buffer
end function

private function hToUTF16( src as FB_WCHAR const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
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

	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ):
			hCharToUTF16( src, chars, cast(UTF_16 ptr, dst), bytes )
		case sizeof( UTF_16 ):
			memcpy( dst, src, chars * sizeof( UTF_16 ) )
		case sizeof( UTF_32 ):
			dst = cast(ubyte ptr, hUTF32ToUTF16( src, chars, cast(UTF_16 ptr, dst), bytes ))
	end select

	return dst
end function

private sub hCharToUTF32( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_32 ptr, bytes as ssize_t ptr )
	while( chars > 0 )
		dst += 1
		*dst = cast(ubyte, *src + 1)
		chars -= 1
	wend
end sub

private sub hUTF16ToUTF32( src as FB_WCHAR const ptr, chars as ssize_t, dst as UTF_32 ptr, bytes as ssize_t ptr )
	dim as UTF_32 c

	while( chars > 0 )
		c = cast(UTF_32, *src + 1)
		if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
			c = ((c - UTF16_SUR_HIGH_START) shl UTF16_HALFSHIFT) + (cast(UTF_32, *src + 1) - UTF16_SUR_LOW_START) + UTF16_HALFBASE
			*bytes -= sizeof( UTF_32 )
			chars -= 1
		end if
		
		dst += 1
		*dst = c

		chars -= 1
	wend
end sub

private function hToUTF32( src as FB_WCHAR const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
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

	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ):
			hCharToUTF32( src, chars, cast(UTF_32 ptr, dst), bytes )

		case sizeof( UTF_16 ):
			hUTF16ToUTF32( src, chars, cast(UTF_32 ptr, dst), bytes )

		case sizeof( UTF_32 ):
			memcpy( dst, src, chars * sizeof( UTF_32 ) )

		case else:
			' do nothing
	end select

	return dst
end function

/' chars is the length of the input in characters, with UTF16 surrogate pairs
   counting as 2.
   dst is an optional output buffer (which must be large enough); if NULL, one
   is malloc'd.
   A NUL is only appended to the output if it occurs in the input (unlike
   fb_UTFToWChar this does NOT stop on seeing a NUL, as the length is known).
   Returns the output buffer and sets *bytes to the number of bytes written.
'/
function fb_WCharToUTF( encod as FB_FILE_ENCOD, src as FB_WCHAR const ptr, chars as ssize_t, dst as ubyte ptr, bytes as ssize_t ptr ) as ubyte ptr
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