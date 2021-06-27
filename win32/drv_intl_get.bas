/' get i18n data '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGet cdecl ( Index as eFbIntlIndex ) as const ubyte ptr
	dim as ubyte buf(0 to 127)
	dim as LCTYPE _lctype

	select case Index
		case eFIL_DateDivider: 
			_lctype = LOCALE_SDATE
		case eFIL_TimeDivider: 
			_lctype = LOCALE_STIME
		case eFIL_NumDecimalPoint: 
			_lctype = LOCALE_SDECIMAL
		case eFIL_NumThousandsSeparator: 
			_lctype = LOCALE_STHOUSAND
		case else:
		return NULL
	end select

	return iif(fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, _lctype, @buf(0), sizeof(buf) - 1 ), @buf(0), NULL)
end function
end extern