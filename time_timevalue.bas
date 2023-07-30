/' timevalue function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_TimeValue FBCALL ( s as FBSTRING ptr ) as double
    dim as long _hour
    dim as long _minute
    dim as long _second
    dim as long succeeded = fb_TimeParse( s, @_hour, @_minute, @_second )

    fb_hStrDelTemp( s )

    if ( succeeded = 0 ) then
        fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        return 0
    end if

    fb_ErrorSetNum( FB_RTERROR_OK )

	return fb_TimeSerial( _hour, _minute, _second )
end function
end extern