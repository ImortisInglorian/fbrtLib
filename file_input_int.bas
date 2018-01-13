/' input function for signed integers '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
function fb_InputInt FBCALL ( dst as long ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		*dst = fb_hStr2Int( @buffer(0), _len )
	else
		*dst = cast(long, rint( fb_hStr2Double( @buffer(0), _len ) ))
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern