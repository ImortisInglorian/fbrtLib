/' get short DATE format '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IntlGetDateFormat( buffer as ubyte ptr, _len as size_t, disallow_localized as long ) as long
    if ( fb_I18nGet( ) <> NULL and disallow_localized = 0 ) then
        if ( fb_DrvIntlGetDateFormat( buffer, _len ) ) then
            return TRUE
		end if
    end if
    if ( _len < 11 ) then
        return FALSE
	end if
    memcpy(buffer, sadd("MM/dd/yyyy"), 11)
    return TRUE
end function
end extern