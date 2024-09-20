/' console mode mouse functions '/

#include "../fb.bi"

extern "C"
function fb_ConsoleGetMouse( x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

function fb_ConsoleSetMouse( x as long, y as long, cursor as long, clip as long ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern