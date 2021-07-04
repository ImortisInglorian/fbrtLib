/' wstring to UTF conversion
 * (based on ConvertUTF.c free implementation from Unicode, Inc)
 '/

#include "fb.bi"

extern "C"

extern __fb_utf8_trailingTb(0 to 255) as const ubyte
extern __fb_utf8_offsetsTb(0 to 5) as const UTF_32

dim shared as const UTF_8 __fb_utf8_bmarkTb(0 to 6) = _
	{ _ 
		&h00, &h00, &hC0, &hE0, &hF0, &hF8, &hFC _
	}

dim shared as const ubyte __fb_utf8_trailingTb(0 to 255) = _
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

dim shared as const UTF_32 __fb_utf8_offsetsTb(0 to 5) = _
	{ _
		&h00000000ul, &h00003080ul, &h000E2080ul, &h03C82080ul, &hFA082080ul, &h82082080ul _
	}

/'
	void fb_hCharToUTF8( const char *src, ssize_t chars, char *dst, ssize_t *total_bytes )

		'src' is the address of the source ascii string and must not
		be null if 'chars' > 0.

		'chars' is  number of ascii characters to convert including
		embedded or terminating null characters.

		'dst' is the destination buffer for the utf-8 encoded string
		and must not be null if 'chars' > 0.

		'total_bytes' is set to the total number of bytes written 
		to 'dst' on return and must not be null if 'chars' > 0.

		no return value
'/

sub fb_hCharToUTF8( src as const ubyte ptr, chars as ssize_t, dst as ubyte ptr, total_bytes as ssize_t ptr )
	dim as UTF_8 c

	*total_bytes = 0
	while( chars > 0 )
		c = *src
		src += 1
		if ( c < &h80 ) then
			*dst = c
			dst += 1
			*total_bytes += 1
		else
			*dst = &hC0 or (c shr 6)
			dst += 1
			*dst = ((c or UTF8_BYTEMARK) and UTF8_BYTEMASK)
			dst += 1
			*total_bytes += 2
		end if

		chars -= 1
	wend
end sub
end extern
