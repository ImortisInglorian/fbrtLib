/' get i18n data '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IntlGet( Index as eFbIntlIndex, disallow_localized as long ) as ubyte ptr
    if( fb_I18nGet() <> NULL and disallow_localized = 0 ) then
        dim as ubyte const ptr pszResult = fb_DrvIntlGet( Index )
        if ( pszResult <> NULL ) then
            return pszResult
        end if
    end if

    select case ( Index )
		case eFIL_DateDivider:
			return sadd("/")
		case eFIL_TimeDivider:
			return sadd(":")
		case eFIL_NumDecimalPoint:
			return sadd(".")
		case eFIL_NumThousandsSeparator:
			return sadd(",")
    end select

    return NULL
end function
end extern