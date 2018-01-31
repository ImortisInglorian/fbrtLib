/' wstring to UTF conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"

dim as UTF_8 __fb_utf8_bmarkTb(0 to 6) = _
	{ _ 
		&h00, &h00, &hC0, &hE0, &hF0, &hF8, &hFC _
	}

dim shared as ubyte __fb_utf8_trailingTb(0 to 255) = _
	{ _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
		2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5 _
	}

dim shared as UTF_32 __fb_utf8_offsetsTb(0 to 5) = _
	{ _
		&h00000000ul, &h00003080ul, &h000E2080ul, &h03C82080ul, &hFA082080ul, &h82082080ul _
	}

extern "C"
sub fb_hCharToUTF8( src as ubyte ptr, chars as ssize_t, dst as ubyte ptr, total_bytes as ssize_t ptr )
	dim as UTF_8 c

	*total_bytes = 0
	while( chars > 0 )
		src += 1
		c = *src
		if ( c < &h80 ) then
			dst += 1
			*dst = c
			*total_bytes += 1
		else
			dst += 1
			*dst = &hC0 or (c shr 6)
			dst += 1
			*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
			*total_bytes += 2
		end if

		chars -= 1
	wend
end sub
end extern