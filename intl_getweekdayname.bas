/' get weekday name '/

#include "fb.bi"

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
function fb_IntlGetWeekdayName( _weekday as long, short_names as long, disallow_localized as long ) as FBSTRING ptr
    dim as FBSTRING ptr res

    if ( _weekday < 1 or _weekday > 7 ) then
        return NULL
	end if

    if ( fb_I18nGet() <> NULL and disallow_localized = 0 ) then
        res = fb_DrvIntlGetWeekdayName( _weekday, short_names )
        if ( res <> NULL ) then
            return res
		end if
    end if
    if ( short_names <> NULL ) then
        res = fb_StrAllocTempDescZ( pszWeekdayNamesShort(_weekday-1) )
    else
        res = fb_StrAllocTempDescZ( pszWeekdayNamesLong(_weekday-1) )
    end if
    if ( res = @__fb_ctx.null_desc ) then
        return NULL
	end if
    return res
end function
end extern