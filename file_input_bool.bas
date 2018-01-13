/' input function for boolean '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
/':::::'/
function fb_InputBool FBCALL ( dst as ubyte ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	*dst = cast(ubyte, fb_hStr2Bool( @buffer(0), _len ))

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern