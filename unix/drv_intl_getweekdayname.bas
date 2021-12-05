/' get localized weekday name '/

#include "../fb.bi"
#include "langinfo.bi"

Function fb_DrvIntlGetWeekdayName( int weekday, int short_names ) as FBSTRING ptr

    dim pszName as const ubyte ptr
    dim result as FBSTRING ptr
    dim name_len as size_t
    dim index as nl_item 

    if( weekday < 1 OrElse weekday > 7 ) then
        return NULL
    end if

    if( short_names ) then
        index = (nl_item) (ABDAY_1 + weekday - 1)
    else
        index = (nl_item) (DAY_1 + weekday - 1)
    end if

    FB_LOCK()

    pszName = nl_langinfo( index )
    if( pszName = NULL ) then
        FB_UNLOCK()
        return NULL
    end if

    name_len = strlen( pszName )

    result = fb_hStrAllocTemp( NULL, name_len )
    if( result <> NULL ) then
        FB_MEMCPY( result->data, pszName, name_len + 1 )
    end if

    FB_UNLOCK()

    return result
End Function
