/' sleep multiplexer function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_SleepEx FBCALL ( msecs as long, kind as long ) as long
    select case ( kind )
		case 0:
			fb_Sleep( msecs )
		case 1:
			fb_Delay( msecs )
		case else:
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select
    return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern