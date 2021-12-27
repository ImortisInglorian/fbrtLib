/' isdate function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IsDate FBCALL ( s as FBSTRING ptr ) as long
    dim as long _year
    dim as long _month
    dim as long _day
    dim as long succeeded = fb_DateParse( s, @_day, @_month, @_year )

    if ( succeeded = 0 ) then
		return 0
	end if

	return -1
end function
end extern