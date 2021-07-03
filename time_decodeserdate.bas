/' functions to decode a serial date number '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
/':::::'/
sub fb_hDateDecodeSerial FBCALL ( serial as double, pYear as long ptr, pMonth as long ptr, pDay as long ptr )
    dim as long tmp_days
    dim as long cur_year = 1900
    dim as long cur_month = 1
    dim as long cur_day = 1

    serial = floor( serial )

    serial -= 2
    while( serial < 0 )
        cur_year -= 1
        serial += fb_hTimeDaysInYear( cur_year )
    wend

	tmp_days = fb_hTimeDaysInYear( cur_year )
    while( serial >= tmp_days )
        serial -= tmp_days
        cur_year += 1
        tmp_days = fb_hTimeDaysInYear( cur_year )
    wend

    if ( pMonth <> 0 or pDay <> 0 ) then
		tmp_days = fb_hTimeDaysInMonth( cur_month, cur_year )
        while( serial >= tmp_days )
            serial -= tmp_days
            cur_month += 1
            tmp_days = fb_hTimeDaysInMonth( cur_month, cur_year )
        wend
    end if

    cur_day += serial

    if ( pYear <> NULL ) then
        *pYear = cur_year
	end if
    if ( pMonth <> NULL ) then
        *pMonth = cur_month
	end if
    if ( pDay <> NULL ) then
        *pDay = cur_day
	end if
end sub

function fb_Year FBCALL ( serial as double ) as long
    dim as long _year
    fb_hDateDecodeSerial( serial, @_year, NULL, NULL )
    return _year
end function

function fb_Month FBCALL ( serial as double ) as long
    dim as long _month
    fb_hDateDecodeSerial( serial, NULL, @_month, NULL )
    return _month
end function

function fb_Day FBCALL ( serial as double ) as long
    dim as long _day
    fb_hDateDecodeSerial( serial, NULL, NULL, @_day )
    return _day
end function

/'* Returns the day of week.
 *
 * @return 1 = Sunday, ... 7 = Saturday
 '/
function fb_Weekday FBCALL ( serial as double, first_day_of_week as long ) as long
    dim as long dow = cast(long, (floor(serial) - 1) mod 7) + 1

    if ( first_day_of_week = FB_WEEK_DAY_SYSTEM ) then
        /' FIXME: query system default '/
        first_day_of_week = FB_WEEK_DAY_DEFAULT
    end if

    dow -= first_day_of_week - 1
    if ( dow < 1 ) then
        dow += 7
    elseif ( dow > 7 ) then
        dow -= 7
    end if
    return dow
end function

/':::::'/
function fb_hGetDayOfYearEx( _year as long, _month as long, _day as long ) as long
    dim as long result = 0
    dim as long cur_month = 1
    while( cur_month <> _month )
        result += fb_hTimeDaysInMonth( cur_month, _year )
        cur_month += 1
	wend
    return result + _day
end function

/':::::'/
function fb_hGetDayOfYear( serial as double ) as long
    dim as long _year, _month, _day
    fb_hDateDecodeSerial( serial, @_year, @_month, @_day )
    return fb_hGetDayOfYearEx( _year, _month, _day )
end function
end extern