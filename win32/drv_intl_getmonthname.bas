/' get localized month name '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGetMonthName ( _month as long, short_names as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as LCTYPE _lctype

	if ( _month < 1 orelse _month > 12 ) then
		return NULL
	end if

	if ( short_names ) then
		_lctype = cast(LCTYPE, (LOCALE_SABBREVMONTHNAME1 + _month - 1))
	else
		_lctype = cast(LCTYPE, (LOCALE_SMONTHNAME1 + _month - 1))
	end if

	Return _GetLocaleString( _lctype, result )
end function
end extern