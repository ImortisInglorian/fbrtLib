/' null pointer checking function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_NullPtrChk FBCALL ( _ptr as any ptr, linenum as long, fname as ubyte const ptr ) as any ptr
	if ( _ptr = NULL ) then
		return cast(any ptr, fb_ErrorThrowEx( FB_RTERROR_NULLPTR, linenum, fname, NULL, NULL ))
	else
		return NULL
	end if
end function
end extern