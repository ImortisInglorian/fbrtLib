/' UTF to wstring conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"

extern "C"

extern as const ubyte __fb_utf8_trailingTb(0 to 255)
extern as const UTF_32 __fb_utf8_offsetsTb(0 to 5)

declare function fb_hUTF8ToChar( src as const UTF_8 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
declare function fb_hUTF16ToChar( src as const UTF_16 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as ubyte ptr
declare function fb_hUTF32ToChar( src as const UTF_32 ptr, dst as ubyte ptr, chars as ssize_t ptr ) as  ubyte ptr

private function hUTF8ToUTF16( src as const UTF_8 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	dim as UTF_32 c
	dim as ssize_t extbytes, charsleft
	dim as FB_WCHAR ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
			extbytes = __fb_utf8_trailingTb(cast(ulong, *src))
			c = 0
			select case( extbytes )

				case 5:
					c += *src
					src += 1
					c shl= 6
				case 4:
					c += *src
					src += 1
					c shl= 6
				case 3:
					c += *src
					src += 1
					c shl= 6
				case 2:
					c += *src
					src += 1
					c shl= 6
				case 1:
					c += *src
					src += 1
					c shl= 6
				case 0:
					c += *src
					src += 1
			end select
	
			c -= __fb_utf8_offsetsTb(extbytes)

			/' Ensure we have room for at least 2 UTF16 units (surrogate pair) '/
			if ( charsleft < 2 ) then
				/' If we still have room for 1 char, reclaim it '/
				dst_size -= charsleft

				/' Make room for some chars '/
				charsleft = 8
				dst_size += charsleft

                dim as FB_WCHAR ptr newbuffer = realloc( buffer, dst_size * sizeof( FB_WCHAR ) )
                if ( newbuffer = NULL ) then
                	free( buffer )
                	return NULL
                end if
				buffer = newbuffer
				dst = buffer + dst_size - charsleft
			end if

			if ( c <= UTF16_MAX_BMP ) then
				*dst = c
				dst += 1
			else
				c -= UTF16_HALFBASE
				*dst = ((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START)
				dst += 1
				*dst = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
				dst += 1
				charsleft -= 1
			end if
	
			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
			extbytes = __fb_utf8_trailingTb(*src)
	
			c = 0
			select case( extbytes )
				case 5:
					c += *src
					src += 1
					c shl= 6
				case 4:
					c += *src
					src += 1
					c shl= 6
				case 3:
					c += *src
					src += 1
					c shl= 6
				case 2:
					c += *src
					src += 1
					c shl= 6
				case 1:
					c += *src
					src += 1
					c shl= 6
				case 0:
					c += *src
					src += 1
			end select
	
			c -= __fb_utf8_offsetsTb(extbytes)

			if ( c <= UTF16_MAX_BMP ) then
				*dst = c
				dst += 1
			else
				c -= UTF16_HALFBASE
				*dst = ((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START)
				dst += 1
				if ( charsleft > 1 ) then
					*dst = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
					dst += 1
					charsleft -= 1
				end if
			end if

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

private function hUTF8ToUTF32( src as const UTF_8 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	dim as UTF_32 c
	dim as ssize_t extbytes, charsleft
	dim as FB_WCHAR ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
			extbytes = __fb_utf8_trailingTb(cast(ulong, *src))
	
			c = 0
			select case( extbytes )
				case 5:
					c += *src
					src += 1
					c shl= 6
				case 4:
					c += *src
					src += 1
					c shl= 6
				case 3:
					c += *src
					src += 1
					c shl= 6
				case 2:
					c += *src
					src += 1
					c shl= 6
				case 1:
					c += *src
					src += 1
					c shl= 6
				case 0:
					c += *src
					src += 1
			end select

			c -= __fb_utf8_offsetsTb(extbytes)

			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				dim as FB_WCHAR ptr newbuffer = realloc( buffer, dst_size * sizeof( FB_WCHAR ) )
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if 
				buffer = newbuffer 
				dst = buffer + dst_size - charsleft
			end if
			
			*dst = c
			dst += 1
	
			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
			extbytes = __fb_utf8_trailingTb(*src)
	
			c = 0
			select case ( extbytes )
				case 5:
					c += *src
					src += 1
					c shl= 6
				case 4:
					c += *src
					src += 1
					c shl= 6
				case 3:
					c += *src
					src += 1
					c shl= 6
				case 2:
					c += *src
					src += 1
					c shl= 6
				case 1:
					c += *src
					src += 1
					c shl= 6
				case 0:
					c += *src
					src += 1
			end select
	
			c -= __fb_utf8_offsetsTb(extbytes)
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

private function hUTF8ToWChar( src as const UTF_8 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr res = NULL
	
	/' convert.. '/
	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ):
			res = cast(FB_WCHAR ptr, fb_hUTF8ToChar( src, cast(ubyte ptr, dst), chars ))

		case sizeof( UTF_16 ):
			res = hUTF8ToUTF16( src, dst, chars )

		case sizeof( UTF_32 ):
			res = hUTF8ToUTF32( src, dst, chars )
	end select
	
	return res
end function

private function hUTF16ToUTF16( src as const UTF_16 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	/' Have to determine and return actual string length '/
	dim as ssize_t _len = 0
	if ( dst = NULL ) then
		while( src[_len] )
			_len += 1
		wend
		dst = malloc( (_len + 1) * sizeof( UTF_16 ) )
		memcpy( dst, src, (_len + 1) * sizeof( UTF_16 ) )
	else
		while( src[_len] and _len < *chars )
			_len += 1
		wend
		memcpy( dst, src, _len * sizeof( UTF_16 ) )
		if (_len < *chars) then
			/' The input buffer has a trailing NUL character, copy it '/
			dst[_len] = 0
		end if
	end if
	*chars = _len
	return dst
end function

private function hUTF16ToUTF32( src as const UTF_16 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	dim as UTF_16 c
	dim as ssize_t charsleft
	dim as FB_WCHAR ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
	    	c = *src and &h0000FFFF
			src += 1
			if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
				c = ((c - UTF16_SUR_HIGH_START) shl UTF16_HALFSHIFT) + (cast(FB_WCHAR, *src) - UTF16_SUR_LOW_START) + UTF16_HALFBASE
				src += 1
	    	end if
	
			if ( charsleft = 0 ) then
				charsleft = 8
				dst_size += charsleft
				dim as FB_WCHAR ptr newbuffer = realloc( buffer, dst_size * sizeof( FB_WCHAR ) ) 
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if
				buffer = newbuffer 
				dst = buffer + dst_size - charsleft
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
			c = *src and &h0000FFFF
			src += 1
			if( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
				c = ((c - UTF16_SUR_HIGH_START) shl UTF16_HALFSHIFT) + (cast(FB_WCHAR,*src) - UTF16_SUR_LOW_START) + UTF16_HALFBASE
				src += 1
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

private function hUTF16ToWChar( src as const UTF_16 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ):
			dst = cast(FB_WCHAR ptr, fb_hUTF16ToChar( src, cast(ubyte ptr, dst), chars ))

		case sizeof( UTF_16 ):
			dst = hUTF16ToUTF16( src, dst, chars )

		case sizeof( UTF_32 ):
			dst = hUTF16ToUTF32( src, dst, chars )
	end select

	return dst
end function

private function hUTF32ToUTF16( src as const UTF_32 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	dim as UTF_32 c
	dim as ssize_t charsleft
	dim as FB_WCHAR ptr buffer = dst
	
    if ( dst = NULL ) then
		dim as ssize_t dst_size = 0
	    charsleft = 0
	    do
			c = *src
			src += 1
			/' Ensure we have room for at least 2 UTF16 units (surrogate pair) '/
			if ( charsleft < 2 ) then
				/' If we still have room for 1 char, reclaim it '/
				dst_size -= charsleft

				/' Make room for some chars '/
				charsleft = 8
				dst_size += charsleft
				dim as FB_WCHAR ptr newbuffer = realloc( buffer, dst_size * sizeof( FB_WCHAR ) )
				if( newbuffer = NULL ) then
					free( buffer )
					return NULL
				end if 
				buffer = newbuffer
				dst = buffer + dst_size - charsleft
			end if
			
			if ( c > UTF16_MAX_BMP ) then
				c -= UTF16_HALFBASE
				*dst = cast(UTF_16, ((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START))
				dst += 1
				c = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
				charsleft -= 1
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit do
			end if
			
			charsleft -= 1
		loop while( 1 )
		
		*chars = dst_size - charsleft
	else
	    charsleft = *chars
	    while( charsleft > 0 )
	    	c = *src
			src += 1

			if ( c > UTF16_MAX_BMP ) then
				c -= UTF16_HALFBASE
				if ( charsleft > 1 ) then
					*dst = cast(UTF_16, ((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START))
					dst += 1
					charsleft -= 1
				end if
				c = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
			end if
			
			*dst = c
			dst += 1

			if ( c = 0 ) then
				exit while
			end if
			
			charsleft -= 1
		wend
		
		*chars -= charsleft
	end if
	
	return buffer
end function

private function hUTF32ToUTF32( src as const UTF_32 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	/' Have to determine and return actual string length '/
	dim as ssize_t _len = 0
	if ( dst = NULL ) then
		while( src[_len] )
			_len += 1
		wend
		dst = malloc( (_len + 1) * sizeof( UTF_32 ) )
		memcpy( dst, src, (_len + 1) * sizeof( UTF_32 ) )
	else
		while( src[_len] and _len < *chars )
			_len += 1
		wend
		memcpy( dst, src, _len * sizeof( UTF_32 ) )
		/' Can't copy trailing NUL character if dst is too small '/
		if (_len < *chars) then
			dst[_len] = 0
		end if
	end if
	*chars = _len
	return dst
end function

private function hUTF32ToWChar( src as const UTF_32 ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ):
			dst = cast(FB_WCHAR ptr, fb_hUTF32ToChar( src, cast(ubyte ptr, dst), chars ))

		case sizeof( UTF_16 ):
			dst = hUTF32ToUTF16( src, dst, chars )

		case sizeof( UTF_32 ):
			dst = hUTF32ToUTF32( src, dst, chars )
	end select
	return dst
end function

/' Convert a NUL-terminated UTF string to FB_WCHARs.
   dst is an output buffer, or NULL to allocate a new one.
   If dst is not NULL, then *chars is the length of the output buffer in
   characters. If it's too short then no trailing NUL character is appended!
   Returns the output buffer and sets *chars to the number of wchars written
   to the buffer, NOT including any trailing NUL, and counting UTF16 surrogate
   pairs (if WCHAR is 16 bit) as 2. '/
function fb_UTFToWChar( encod as FB_FILE_ENCOD, src as const any ptr, dst as FB_WCHAR ptr, chars as ssize_t ptr ) as FB_WCHAR ptr
	select case ( encod )
		case FB_FILE_ENCOD_UTF8:
			return hUTF8ToWChar( src, dst, chars )

		case FB_FILE_ENCOD_UTF16:
			return hUTF16ToWChar( src, dst, chars )

		case FB_FILE_ENCOD_UTF32:
			return hUTF32ToWChar( src, dst, chars )

		case else:
			return NULL
	end select
end function
end extern