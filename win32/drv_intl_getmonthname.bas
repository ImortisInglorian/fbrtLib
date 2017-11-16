/' get localized month name '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGetMonthName cdecl ( _month as long, short_names as long ) as FBSTRING ptr
	dim as ubyte ptr pszName = NULL
	dim as size_t name_len
	dim as LCTYPE _lctype
	dim as FBSTRING ptr result

	if ( _month < 1 or _month > 12 ) then
		return NULL
	end if

	if ( short_names ) then
		_lctype = cast(LCTYPE, (LOCALE_SABBREVMONTHNAME1 + _month - 1))
	else
		_lctype = cast(LCTYPE, (LOCALE_SMONTHNAME1 + _month - 1))
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