/' get weekday name '/

#include "fb.bi"
#include "destruct_string.bi"

dim shared as ubyte ptr pszWeekdayNamesLong(0 to 6) = { _
    @"Sunday", _
    @"Monday", _
    @"Tuesday", _
    @"Wednesday", _
    @"Thursday", _
    @"Friday", _
    @"Saturday" _
}

dim shared as ubyte ptr pszWeekdayNamesShort(0 to 6) = { _
    @"Sun", _
    @"Mon", _
    @"Tue", _
    @"Wed", _
    @"Thu", _
    @"Fri", _
    @"Sat" _
}

extern "C"
/':::::'/
function fb_IntlGetWeekdayName( _weekday as long, short_names as long, disallow_localized as long, result as FBSTRING ptr ) as FBSTRING ptr
    dim as destructable_string res
    dim as ubyte ptr ptr days_array
    dim as ubyte ptr day_name

    DBG_ASSERT( result <> NULL )

    if ( _weekday < 1 orelse _weekday > 7 ) then
        return NULL
    end if

    if ( fb_I18nGet() <> NULL andalso disallow_localized = 0 ) then
        if( fb_DrvIntlGetWeekdayName( _weekday, short_names, @res ) <> Null ) then
            Goto goodexit
	end if
    end if
    days_array = Iif( short_names <> 0, @pszWeekdayNamesShort(0), @pszWeekdayNamesLong(0))
    day_name = days_array[_weekday - 1]
    fb_StrAllocDescZEx( day_name, strlen(day_name), @res )

goodExit:
    fb_StrSwapDesc( @res, result )
    return result
end function
end extern