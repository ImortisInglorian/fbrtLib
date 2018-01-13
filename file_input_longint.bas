/' input function for signed long long's '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
function fb_InputLongint FBCALL ( dst as longint ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		if ( _len <= FB_INPUT_MAXINTLEN ) then
			*dst = fb_hStr2Int( @buffer(0), _len )
		else
			*dst = fb_hStr2Longint( @buffer(0), _len )
		end if
	else
		*dst = cast(longint, rint( fb_hStr2Double( @buffer(0), _len ) ))
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern