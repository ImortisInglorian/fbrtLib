/' setdate function '/

#include "fb.bi"
#include "crt/ctype.bi"

/'* Sets the date to the specified value.
 *
 * Valid formats:
 * - mm/dd/yy
 * - mm/dd/yyyy
 * - mm-dd-yy
 * - mm-dd-yyyy
 *
 * VBDOS converts a 2-digit year by adding 1900.
 *
 * @see fb_Date()
 '/
extern "C"
function fb_SetDate FBCALL ( _date as FBSTRING ptr ) as long
	if ( (_date <> NULL) andalso (_date->data <> NULL) ) then
		dim as ubyte ptr t
		dim as ubyte c, sep
		dim as long m, d, y

		/' get month '/
		m = 0
		'for( t = date->data; (c = *t) && isdigit(c); t++ )
		while (c = *t and isdigit(c) = TRUE)
			m = m * 10 + c - asc("0")
			t += 1
		wend

		if ( ((c <> asc("/")) and (c <> asc("-"))) or (m < 1) or (m > 12) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
		sep = c

		/' get day '/
		d = 0
		t +=1
		'for( t++; (c = *t) && isdigit(c); t++ )
		while (c = *t and isdigit(c) = TRUE)
			d = d * 10 + c - asc("0")
			t += 1
		wend

		if ( (c <> sep) or (d < 1) or (d > 31) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if

		/' get year '/
		y = 0
		t += 1
		'for( t++; (c = *t) && isdigit(c); t++ )
		while (c = *t and isdigit(c) = TRUE)
			y = y * 10 + c - asc("0")
			t += 1
		wend

		if (y < 100) then y += 1900

		if ( fb_hSetDate( y, m, d ) <> 0 ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( _date )

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern