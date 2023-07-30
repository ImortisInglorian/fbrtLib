/' datevalue function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_DateValue FBCALL ( s as FBSTRING ptr ) as long
    dim as long _year
    dim as long _month
    dim as long _day
    dim as long succeeded = fb_DateParse( s, @_day, @_month, @_year )

    fb_hStrDelTemp( s )

    if ( succeeded = 0 ) then
        fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        return 0
    end if

    fb_ErrorSetNum( FB_RTERROR_OK )

	return fb_DateSerial( _year, _month, _day )
end function
end extern