/' input function for usigned shorts '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
function fb_InputUshort FBCALL ( dst as ushort ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		*dst = cast(ushort, fb_hStr2UInt( @buffer(0), _len ))
	else
		*dst = cast(ushort, rint( fb_hStr2Double( @buffer(0), _len ) ))
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern