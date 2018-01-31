/' print using function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_LPrintUsingInit FBCALL ( fmtstr as FBSTRING ptr ) as long
    dim as long res = fb_LPrintInit()
    if ( res <> FB_RTERROR_OK ) then
        return res
	end if
	return fb_PrintUsingInit( fmtstr )
end function
end extern