/' get month name '/

#include "fb.bi"

dim shared as ubyte ptr pszMonthNamesLong(0 to 11) = { _
    @"January", _
    @"February", _
    @"March", _
    @"April", _
    @"May", _
    @"June", _
    @"July", _
    @"August", _
    @"September", _
    @"October", _
    @"November", _
    @"December" _
}

dim shared as ubyte ptr pszMonthNamesShort(0 to 11) = { _
    @"Jan", _
    @"Feb", _
    @"Mar", _
    @"Apr", _
    @"May", _
    @"Jun", _
    @"Jul", _
    @"Aug", _
    @"Sep", _
    @"Oct", _
    @"Nov", _
    @"Dec" _
}

extern "C"
/':::::'/
function fb_IntlGetMonthName( _month as long, short_names as long, disallow_localized as long ) as FBSTRING ptr
    dim as FBSTRING ptr res

    if ( _month < 1 or _month > 12 ) then
        return NULL
	end if

    if ( fb_I18nGet() <> NULL and disallow_localized = 0 ) then
        res = fb_DrvIntlGetMonthName( _month, short_names )
        if ( res <> NULL ) then
            return res
		end if
    end if
    if ( short_names <> NULL ) then
        res = fb_StrAllocTempDescZ( pszMonthNamesShort(_month-1) )
    else
        res = fb_StrAllocTempDescZ( pszMonthNamesLong(_month-1) )
    end if
    if ( res = @__fb_ctx.null_desc ) then
        return NULL
	end if
    return res
end function
end extern