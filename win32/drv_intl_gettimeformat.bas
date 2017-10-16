/' get localized short TIME format '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
function fb_DrvIntlGetTimeFormat cdecl ( buffer as ubyte ptr, _len as size_t ) as long
	dim as ubyte achFormat(0 to 89), achHourZero(0 to 7), achTimeMark(0 to 7), achTimeMarkPos(0 to 7)
	dim as ubyte ptr pszFormat, pszHourZero, pszTimeMark, pszTimeMarkPos
    dim as long use_timemark, timemark_prefix
    dim as size_t i

    DBG_ASSERT(buffer <> NULL)

    /' Can I use this? The problem is that it returns the date format
     * with localized separators. '/
    pszFormat = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_STIMEFORMAT, @achFormat(0), sizeof(achFormat) - 1 )
    if ( pszFormat <> NULL ) then
        dim as size_t uiNameSize = strlen(pszFormat)
        if ( uiNameSize < _len ) then
            strcpy( buffer, pszFormat )
            return TRUE
        else
            return FALSE
        end if
    end if


    /' Fall back for Win95 and WinNT < 4.0 '/
    pszTimeMarkPos = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_ITIMEMARKPOSN, @achTimeMarkPos(0), sizeof(achTimeMarkPos) )
    pszTimeMark = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_ITIME, @achTimeMark(0), sizeof(achTimeMark) )
    pszHourZero = fb_hGetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_ITLZERO, @achHourZero(0), sizeof(achHourZero) )

    i = 0

    use_timemark = ( pszTimeMark <> NULL and atoi( pszTimeMark ) = 1 )
    timemark_prefix = ( pszTimeMarkPos <> NULL and atoi( pszTimeMarkPos ) = 1 )

    if ( use_timemark and timemark_prefix ) then
        strcpy( @achFormat(0) + i, sadd("AM/PM ") )
        i += 6
    end if

    if ( pszHourZero <> NULL and atoi( pszHourZero ) = 1 ) then
        if ( not(use_timemark) ) then
            strcpy( @achFormat(0) + i, sadd("HH:") )
        else
            strcpy( @achFormat(0) + i, sadd("hh:") )
        end if
        i += 3
    end if
    strcpy( @achFormat(0) + i, sadd("mm:ss") )
    i += 5

    if ( use_timemark and not(timemark_prefix) ) then
        strcpy( @achFormat(0) + i, sadd(" AM/PM") )
        i += 6
    end if

    if ( _len < (i + 1) ) then
        return FALSE
	end if

    FB_MEMCPY(buffer, @achFormat(0), i)
    buffer[i] = 0

    return TRUE
end function
end extern