/' input function '/

#include "fb.bi"

extern "C"
function fb_InputString FBCALL ( dst as any ptr, _strlen as ssize_t, fillrem as long ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXSTRINGLEN)
	dim as long isfp

	fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXSTRINGLEN, TRUE, @isfp )

	fb_StrAssign( dst, _strlen, @buffer(0), 0, fillrem )

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern