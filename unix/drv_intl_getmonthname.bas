/' get localized month name '/

#include "../fb.bi"
#include "../destruct_string.bi"
#include "langinfo.bi"

Function fb_DrvIntlGetMonthName( month as long, short_names as long, result as FBSTRING ptr ) as FBSTRING ptr

    dim index as nl_item

    DBG_ASSERT( result <> NULL )

    if( month < 1 OrElse month > 12 ) then
        return NULL
    end if

    if( short_names ) then
        index = (nl_item) (ABMON_1 + month - 1)
    else
        index = (nl_item) (MON_1 + month - 1)
    end if

    return GetLocalString( index, result )
End Function

Private Function _GetLocaleString ( index as nl_item, result as FBSTRING ptr ) as FBSTRING ptr
    dim as destructable_string tmp_str
    dim pszName as const ubyte ptr
    dim name_len as size_t

    '' For nl_langinfo which mightn't be threadsafe
    FB_LOCK()

    pszName = nl_langinfo( index )
    if( pszName <> NULL ) then

        name_len = strlen( pszName )

        if( fb_hStrAlloc( @tmp_str, name_len ) <> NULL ) then
            FB_MEMCPY( tmp_str.data, pszName, name_len + 1 )
        end if
    end if

    FB_UNLOCK()

    fb_StrSwapDesc( @tmp_str, result )
    return result
End Function