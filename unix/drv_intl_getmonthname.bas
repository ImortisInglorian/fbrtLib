/' get localized month name '/

#include "../fb.bi"
#include "langinfo.bi"

Function fb_DrvIntlGetMonthName( month as long, short_names as long ) as FBSTRING ptr

    dim pszName as const ubyte ptr
    dim result as FBSTRING ptr
    dim name_len as size_t
    dim index as nl_item 

    if( month < 1 OrElse month > 12 ) then
        return NULL
    end if

    if( short_names ) then
        index = (nl_item) (ABMON_1 + month - 1)
    else
        index = (nl_item) (MON_1 + month - 1)
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
