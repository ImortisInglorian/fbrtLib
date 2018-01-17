/' get short TIME format '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IntlGetTimeFormat( buffer as ubyte ptr, _len as size_t, disallow_localized as long ) as long
    if ( fb_I18nGet() <> NULL and disallow_localized = 0 ) then
        if ( fb_DrvIntlGetTimeFormat( buffer, _len ) <> NULL ) then
            return TRUE
		end if
    end if
    if ( _len < 9 ) then
        return FALSE
	end if
    strcpy(buffer, "HH:mm:ss")
    return TRUE
end function
end extern