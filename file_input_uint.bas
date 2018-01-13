/' input function for unsigned integers '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
function fb_InputUint FBCALL ( dst as ulong ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		*dst = fb_hStr2UInt( @buffer(0), _len )
	else
		*dst = cast(ulong, rint( fb_hStr2Double( @buffer(0), _len ) ))
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern