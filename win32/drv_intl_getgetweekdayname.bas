/' get localized weekday name '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGetWeekdayName cdecl ( _weekday as long, short_names as long ) as FBSTRING ptr
    dim as ubyte ptr pszName = NULL
    dim as size_t name_len
    dim as LCTYPE _lctype
    dim as FBSTRING ptr result

    if ( _weekday < 1 or _weekday > 7 ) then
        return NULL
	end if

    if ( _weekday = 1 ) then
        _weekday = 8
	end if

    if ( short_names ) then
        _lctype = cast(LCTYPE, (LOCALE_SABBREVDAYNAME1 + _weekday - 2))
    else
        _lctype = cast(LCTYPE, (LOCALE_SDAYNAME1 + _weekday - 2))
    end if

    pszName = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, _lctype, NULL, 0 )
    if ( pszName = NULL ) then
        return NULL
	end if

    name_len = strlen(pszName)

    result = fb_hStrAllocTemp( NULL, name_len )
    if ( result <> NULL ) then
        /' !!!FIXME!!! GetCodepage() should become a hook function for console and gfx modes '/
        dim as long target_cp = GetConsoleCP() /'iif( FB_GFX_ACTIVE(), FB_GFX_GET_CODEPAGE(), GetConsoleCP() )'/
        if ( target_cp <> -1 ) then
            FB_MEMCPY( result->data, pszName, name_len + 1 )
            result = fb_hIntlConvertString( result, CP_ACP, target_cp )
        end if
    end if

   free( pszName )

    return result
end function
end extern