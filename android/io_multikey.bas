/' console multikey() '/

#include "../fb.bi"

extern "C"
function fb_ConsoleMultikey ( scancode as long ) as long
	fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	return FB_FALSE
end function
end extern