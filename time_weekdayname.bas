/' returns the weekday name '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_WeekdayName FBCALL ( _weekday as long, abbreviation as long, first_day_of_week as long ) as FBSTRING ptr
    dim as FBSTRING ptr res

    if ( _weekday < 1 or _weekday > 7 or first_day_of_week < 0 or first_day_of_week > 7 ) then
        fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
        return @__fb_ctx.null_desc
    end if

    fb_ErrorSetNum( FB_RTERROR_OK )

    if ( first_day_of_week = FB_WEEK_DAY_SYSTEM ) then
        /' FIXME: Add query of system default '/
        first_day_of_week = FB_WEEK_DAY_DEFAULT
    end if

    _weekday += first_day_of_week - 1
    if ( _weekday > 7 ) then
        _weekday -= 7
	end if

    res = fb_IntlGetWeekdayName( _weekday, abbreviation, FALSE )
    if( res = NULL ) then
        fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
        res = @__fb_ctx.null_desc
    end if

    return res
end function
end extern