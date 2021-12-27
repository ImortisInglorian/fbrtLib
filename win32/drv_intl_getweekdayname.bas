/' get localized weekday name '/

#include "../fb.bi"
#include "fb_private_intl.bi"
#include "../destruct_string.bi"

extern "C"
function fb_DrvIntlGetWeekdayName ( _weekday as long, short_names as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as LCTYPE _lctype

	if ( _weekday < 1 orelse _weekday > 7 ) then
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

	Return _GetLocaleString ( _lctype, result )
end function
end extern

private function _GetLocaleString ( info as LCTYPE, result as FBSTRING ptr ) as FBSTRING ptr
	dim as ubyte ptr pszName
	dim as size_t name_len

	pszName = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, info, NULL, 0 )
	if ( pszName = NULL ) then
		return NULL
	end if

	name_len = strlen(pszName)

	'' we don't need to copy this, and it's not the strings' data to free
	dim as FBSTRING stack_str
	fb_StrAllocDescZEx( pszName, name_len, @stack_str )

	dim as destructable_string tmp_str
	/' !!!FIXME!!! GetCodepage() should become a hook function for console and gfx modes '/
	dim as long target_cp = GetConsoleCP() /'iif( FB_GFX_ACTIVE(), FB_GFX_GET_CODEPAGE(), GetConsoleCP() )'/
	if ( target_cp <> -1 ) then
		result = fb_hIntlConvertString( @stack_str, CP_ACP, target_cp, @tmp_str )
	end if

	DeAllocate( pszName )
	stack_str.data = Null

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function