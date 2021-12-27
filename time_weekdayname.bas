/' returns the weekday name '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_WeekdayName FBCALL ( _weekday as long, abbreviation as long, first_day_of_week as long, result as FBSTRING ptr ) as FBSTRING ptr
    dim as destructable_string tmp_str
    dim as long _err = FB_RTERROR_ILLEGALFUNCTIONCALL

    DBG_ASSERT( result <> NULL )

    if ( _weekday >= 1 andalso _weekday <= 7 andalso first_day_of_week >= 0 andalso first_day_of_week <= 7 ) then

        _err = FB_RTERROR_OK

        if ( first_day_of_week = FB_WEEK_DAY_SYSTEM ) then
            /' FIXME: Add query of system default '/
            first_day_of_week = FB_WEEK_DAY_DEFAULT
        end if

        _weekday += first_day_of_week - 1
        if ( _weekday > 7 ) then
            _weekday -= 7
	end if

        if( fb_IntlGetWeekdayName( _weekday, abbreviation, FALSE, @tmp_str ) = NULL ) then
            _err = FB_RTERROR_ILLEGALFUNCTIONCALL
        end if
    end if

    fb_StrSwapDesc( @tmp_str, result )
    fb_ErrorSetNum( _err )
    return result
end function
end extern