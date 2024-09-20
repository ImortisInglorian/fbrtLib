/' ports I/O functions '/

#include "../fb.bi"

extern "C"
function fb_hIn( port as ushort ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

function fb_hOut( port as ushot, value as ubyte ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern