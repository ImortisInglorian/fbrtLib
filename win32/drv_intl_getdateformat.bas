/' get localized short DATE format '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGetDateFormat cdecl ( buffer as ubyte ptr, _len as size_t ) as long
	dim as ubyte ptr pszName
	dim as ubyte ptr achOrder = NULL
	dim as ubyte achFormat(0 to 89)
	dim as ubyte achDayZero(0 to 1), achMonZero(0 to 1), achDate(0 to 1)
	dim as ubyte ptr pszDayZero, pszMonZero, pszDate
	dim as size_t i

	DBG_ASSERT(buffer <> NULL)

	/' Can I use this? The problem is that it returns the date format
	 * with localized separators. '/
	pszName = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_SSHORTDATE, @achFormat(0), ARRAY_SIZEOF(achFormat) - 1 )
	if ( pszName <> NULL ) then
		dim as size_t uiNameSize = strlen(pszName)
		if ( uiNameSize < _len ) then
			strcpy( buffer, pszName )
			return TRUE
		else
			return FALSE
		end if
	end if


	/' Fall back for Win95 and WinNT < 4.0 '/
	pszDayZero = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_IDAYLZERO, @achDayZero(0), ARRAY_SIZEOF(achDayZero) )
	pszMonZero = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_IMONLZERO, @achMonZero(0), ARRAY_SIZEOF(achMonZero) )
	pszDate = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_IDATE, @achDate(0), ARRAY_SIZEOF(achDate) )
	if ( pszDate <> NULL andalso pszDayZero <> 0 andalso pszMonZero <> 0 ) then
		select case( atoi( pszDate ) )
			case 0:
				achOrder = sadd("mdy")
			case 1:
				achOrder = sadd("dmy")
			case 2:
				achOrder = sadd("ymd")
		end select

		if ( achOrder <> NULL ) then
			dim as size_t remaining = _len - 1
			dim as long day_lead_zero = atoi( pszDayZero ) <> 0
			dim as long mon_lead_zero = atoi( pszMonZero ) <> 0
			for i=0 to 2
				dim as ubyte ptr pszAdd = NULL
				dim as size_t add_len
				select case ( achOrder[i] )
					case asc("m"):	' m
						if ( mon_lead_zero ) then
							pszAdd = sadd("MM")
						else
							pszAdd = sadd("M")
						end if
					case asc("d"): 	' d
						if ( day_lead_zero ) then
							pszAdd = sadd("dd")
						else
							pszAdd = sadd("d")
						end if
					case asc("y"): 	' y
						pszAdd = sadd("yyyy")
				end select
				add_len = strlen(pszAdd)
				if ( remaining < add_len ) then
					return FALSE
				end if
				strcpy( buffer, pszAdd )
				buffer += add_len
				remaining -= add_len
				if ( i <> 2 ) then
					if ( remaining = 0 ) then
						return FALSE
					end if
					strcpy( buffer, "/" )
					buffer += 1
					remaining -= 1
				end if
			next
			return TRUE
		end if
	end if

	return FALSE
end function
end extern