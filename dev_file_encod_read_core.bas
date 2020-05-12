/' UTF-encoded to char or wchar file reading
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"

extern "C"

extern __fb_utf8_trailingTb(0 to 255) as ubyte ptr
extern __fb_utf8_offsetsTb(0 to 5) as UTF_32

/'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*
 * to char                                                                              *
 *::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/

private function hReadUTF8ToChar( fp as FILE ptr, dst as ubyte ptr, max_chars as ssize_t ) as ssize_t
	dim as UTF_32 wc
	dim as ubyte ptr c(0 to 6)
	dim as ubyte ptr p
	dim as ssize_t chars, extbytes

	chars = max_chars
    while( chars > 0 )
		if( fread( c(0), 1, 1, fp ) <> 1 ) then
			exit while
		end if

		extbytes = cast(ssize_t, *__fb_utf8_trailingTb(*c(0)))

		if ( extbytes > 0 ) then
			if( fread( c(1), extbytes, 1, fp ) <> 1 ) then
				exit while
			end if
		end if
		
		wc = 0
		p = c(0)
		select case ( extbytes )
			case 5:
				wc += *p + 1
				wc shl= 6
			case 4:
				wc += *p + 1
				wc shl= 6
			case 3:
				wc += *p + 1
				wc shl= 6
			case 2:
				wc += *p + 1
				wc shl= 6
			case 1:
				wc += *p + 1
				wc shl= 6
			case 0:
				wc += *p + 1
		end select

		wc -= __fb_utf8_offsetsTb(extbytes)

		if ( wc > 255 ) then
			wc = asc("?")
		end if
		dst += 1
		*dst = wc
		chars -= 1
	wend

	return max_chars - chars
end function

private function hReadUTF16ToChar( fp as FILE ptr, dst as ubyte ptr, max_chars as ssize_t ) as ssize_t
	dim as ssize_t chars
	dim as UTF_16 c

	chars = max_chars
    while( chars > 0 )
    	if( fread( @c, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
    		exit while
		end if

		if( c > 255 ) then
			if( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
    			if( fread( @c, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
    				exit while
				end if
    		end if
    		c = asc("?")
    	end if
		dst += 1
		*dst = c
		chars -= 1
	wend

	return max_chars - chars
end function

private function hReadUTF32ToChar( fp as FILE ptr, dst as ubyte ptr, max_chars as ssize_t ) as ssize_t
	dim as ssize_t chars
	dim as UTF_32 c

	chars = max_chars
    while ( chars > 0 )
    	if ( fread( @c, sizeof( UTF_32 ), 1, fp ) <> 1 ) then
    		exit while
		end if

		if ( c > 255 ) then
			c = asc("?")
		end if
		dst += 1
		*dst = c
		chars -= 1
	wend

	return max_chars - chars
end function

function fb_hFileRead_UTFToChar( fp as FILE ptr, encod as FB_FILE_ENCOD, dst as ubyte ptr, max_chars as ssize_t ) as ssize_t
	select case ( encod )
		case FB_FILE_ENCOD_UTF8:
			return hReadUTF8ToChar( fp, dst, max_chars )

		case FB_FILE_ENCOD_UTF16:
			return hReadUTF16ToChar( fp, dst, max_chars )

		case FB_FILE_ENCOD_UTF32:
			return hReadUTF32ToChar( fp, dst, max_chars )
			
		case else:
			return 0
	end select
end function

/'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*
 * to wchar                                                                             *
 *::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'/

private function hUTF8ToUTF16( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	dim as UTF_32 wc
	dim as ubyte ptr c(0 to 6)
	dim as ubyte ptr p
	dim as ssize_t chars, extbytes

	chars = max_chars
    while ( chars > 0 )
		if( fread( c(0), 1, 1, fp ) <> 1 ) then
			exit while
		end if

		extbytes = cast(ssize_t, *__fb_utf8_trailingTb(*c(0)))

		if ( extbytes > 0 ) then
			if( fread( c(1), extbytes, 1, fp ) <> 1 ) then
				exit while
			end if
		end if

		wc = 0
		p = c(0)
		select case ( extbytes )
			case 5:
				wc += *p + 1
				wc shl= 6
			case 4:
				wc += *p + 1
				wc shl= 6
			case 3:
				wc += *p + 1
				wc shl= 6
			case 2:
				wc += *p + 1
				wc shl= 6
			case 1:
				wc += *p + 1
				wc shl= 6
			case 0:
				wc += *p + 1
		end select

		wc -= __fb_utf8_offsetsTb(extbytes)

		if ( wc <= UTF16_MAX_BMP ) then
			dst += 1
			*dst = wc
		else
			if ( chars > 1 ) then
				wc -= UTF16_HALFBASE
				dst += 1
				*dst = ((wc shr UTF16_HALFSHIFT) +	UTF16_SUR_HIGH_START)
				*dst = ((wc and UTF16_HALFMASK)	+ UTF16_SUR_LOW_START)
				chars -= 1
			end if
		end if

		chars -= 1
	wend

	return max_chars - chars
end function

private function hUTF8ToUTF32( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	dim as UTF_32 wc
	dim as ubyte ptr c(0 to 6) 
	dim as ubyte ptr p
	dim as ssize_t chars, extbytes

	chars = max_chars
    while ( chars > 0 )
		if( fread( @c(0), 1, 1, fp ) <> 1 ) then
			exit while
		end if

		extbytes = cast(ssize_t, __fb_utf8_trailingTb(*c(0)))

		if ( extbytes > 0 ) then
			if ( fread( @c(1), extbytes, 1, fp ) <> 1 ) then
				exit while
			end if
		end if

		wc = 0
		p = c(0)
		select case ( extbytes )
			case 5:
				wc += *p + 1
				wc shl= 6
			case 4:
				wc += *p + 1
				wc shl= 6
			case 3:
				wc += *p + 1
				wc shl= 6
			case 2:
				wc += *p + 1
				wc shl= 6
			case 1:
				wc += *p + 1
				wc shl= 6
			case 0:
				wc += *p + 1
		end select

		wc -= __fb_utf8_offsetsTb(extbytes)
		dst += 1
		*dst = wc
		chars -= 1
	wend

	return max_chars - chars
end function

private function hReadUTF8ToWchar( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	dim as ssize_t res = 0

	/' convert.. '/
	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ptr ):
			res = hReadUTF8ToChar( fp, cast(ubyte ptr, dst), max_chars )

		case sizeof( UTF_16 ):
			res = hUTF8ToUTF16( fp, dst, max_chars )

		case sizeof( UTF_32 ):
			res = hUTF8ToUTF32( fp, dst, max_chars )
	end select

	return res
end function

private function hUTF16ToUTF32( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
    dim as UTF_32 c, c2
	dim as ssize_t chars

    chars = max_chars
    while ( chars > 0 )
    	if( fread( @c, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
    		exit while
		end if

		c and= &h0000FFFF
		if ( c >= UTF16_SUR_HIGH_START and c <= UTF16_SUR_HIGH_END ) then
    		if( fread( @c2, sizeof( UTF_16 ), 1, fp ) <> 1 ) then
    			exit while
			end if

			c = ((c - UTF16_SUR_HIGH_START) shl UTF16_HALFSHIFT) + (c2 - UTF16_SUR_LOW_START) + UTF16_HALFBASE
		end if
		
		dst += 1
		*dst = c
		chars -= 1
    wend

	return max_chars - chars
end function

private function hReadUTF16ToWchar( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	dim as ssize_t res = 0

	/' same size? '/
	if ( sizeof( FB_WCHAR ) = sizeof( UTF_16 ) ) then
		return fread( cast(ubyte ptr, dst), sizeof( UTF_16 ), max_chars, fp )
	end if

	/' convert.. '/
	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ptr ):
			res = hReadUTF16ToChar( fp, cast(ubyte ptr, dst), max_chars )

		case sizeof( UTF_32 ):
			res = hUTF16ToUTF32( fp, dst, max_chars )
	end select

	return res
end function

private function hUTF32ToUTF16( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
    dim as UTF_32 c
	dim as ssize_t chars

    chars = max_chars
    while ( chars > 0 )
    	if( fread( @c, sizeof( UTF_32 ), 1, fp ) <> 1 ) then
    		exit while
		end if

		if ( c > UTF16_MAX_BMP ) then
			c -= UTF16_HALFBASE
			if ( chars > 1 ) then
				dst += 1
				*dst = cast(UTF_16, ((c shr UTF16_HALFSHIFT) + UTF16_SUR_HIGH_START))
				chars -= 1
			end if
			c = ((c and UTF16_HALFMASK) + UTF16_SUR_LOW_START)
		end if

		dst += 1
		*dst = cast(UTF_16, c)
		chars -= 1
    wend

	return max_chars - chars
end function

private function hReadUTF32ToWchar( fp as FILE ptr, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	dim as ssize_t res = 0

	select case ( sizeof( FB_WCHAR ) )
		case sizeof( ubyte ptr ):
			res = hReadUTF32ToChar( fp, cast(ubyte ptr, dst), max_chars )

		case sizeof( UTF_16 ):
			res = hUTF32ToUTF16( fp, dst, max_chars )

		case sizeof( UTF_32 ):
			res = fread( cast(ubyte ptr, dst), sizeof( UTF_32 ), max_chars, fp )
	end select

	return res
end function

function fb_hFileRead_UTFToWchar( fp as FILE ptr, encod as FB_FILE_ENCOD, dst as FB_WCHAR ptr, max_chars as ssize_t ) as ssize_t
	select case ( encod )
		case FB_FILE_ENCOD_UTF8:
			return hReadUTF8ToWchar( fp, dst, max_chars )
			
		case FB_FILE_ENCOD_UTF16:
			return hReadUTF16ToWchar( fp, dst, max_chars )

		case FB_FILE_ENCOD_UTF32:
			return hReadUTF32ToWchar( fp, dst, max_chars )

		case else:
			return 0
	end select

end function
end extern
