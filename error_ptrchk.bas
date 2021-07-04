/' null pointer checking function '/

#ifdef fb_NullPtrChk
	#undef fb_NullPtrChk
#endif

#include "fb.bi"

extern "C"
/':::::'/
function fb_NullPtrChk FBCALL ( _ptr as any ptr, linenum as long, fname as const ubyte ptr ) as any ptr
	if ( _ptr = NULL ) then
		return cast(any ptr, fb_ErrorThrowEx( FB_RTERROR_NULLPTR, linenum, fname, NULL, NULL ))
	else
		return NULL
	end if
end function
end extern