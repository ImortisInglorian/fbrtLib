/' get localized weekday name '/

#include "../fb.bi"
#include "langinfo.bi"

'' implemented in drv_intl_getmonthname
Declare Function _GetLocaleString ( index as nl_item, result as FBSTRING ptr ) as FBSTRING ptr

Function fb_DrvIntlGetWeekdayName( int weekday, int short_names, result as FBSTRING ptr ) as FBSTRING ptr

    dim index as nl_item

    DBG_ASSERT( result <> NULL )

    if( weekday < 1 OrElse weekday > 7 ) then
        return NULL
    end if

    if( short_names ) then
        index = (nl_item) (ABDAY_1 + weekday - 1)
    else
        index = (nl_item) (DAY_1 + weekday - 1)
    end if

    return _GetLocaleString( index, result )
End Function
