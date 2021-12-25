/' get month name '/

#include "fb.bi"
#include "destruct_string.bi"

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
function fb_IntlGetMonthName( _month as long, short_names as long, disallow_localized as long, result as FBSTRING ptr ) as FBSTRING ptr
    dim as destructable_string res
    dim as ubyte ptr ptr months_array
    dim as ubyte ptr month_name

    DBG_ASSERT( result <> NULL )

    if ( _month < 1 orelse _month > 12 ) then
        return NULL
    end if

    if ( fb_I18nGet() <> NULL andalso disallow_localized = 0 ) then
        if ( fb_DrvIntlGetMonthName( _month, short_names, @res ) <> Null ) then
            Goto goodExit
        end if
    end if
    months_array = Iif( short_names <> 0, @pszMonthNamesShort(0), @pszMonthNamesLong(0))
    month_name = months_array[_month - 1]
    fb_StrAllocDescZEx( month_name, strlen(month_name), @res )

goodExit:
    fb_StrSwapDesc( @res, result )
    return result
end function
end extern