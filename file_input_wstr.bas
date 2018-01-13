/' input function for wstring's '/

#include "fb.bi"

extern "C"
function fb_InputWstr FBCALL ( _str as FB_WCHAR ptr, length as ssize_t ) as long
	dim as FB_WCHAR buffer(0 to FB_INPUT_MAXSTRINGLEN)

	fb_FileInputNextTokenWstr( @buffer(0), FB_INPUT_MAXSTRINGLEN, TRUE )

	fb_WstrAssign( _str, length, @buffer(0) )
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern