/' dateserial function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_DateSerial FBCALL ( _year as long, _month as long, _day as long ) as long
    dim as long result = 2
    dim as long cur_year = 1900
    dim as long cur_month = 1
    dim as long cur_day = 1

    fb_hNormalizeDate( @_day, @_month, @_year )

    if ( cur_year < _year ) then
        while ( cur_year <> _year )
            result += fb_hTimeDaysInYear( cur_year )
            cur_year += 1
        wend
    else
        while ( cur_year <> _year )
            result -= fb_hTimeDaysInYear( cur_year )
            cur_year -= 1
        wend
    end if

    while ( cur_month <> _month )
        result += fb_hTimeDaysInMonth( cur_month, _year )
        cur_month += 1
    wend

    result += _day - cur_day

	return result
end function
end extern