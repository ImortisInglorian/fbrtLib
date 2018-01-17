/' turns internationalization on/off and queries status '/

#include "fb.bi"

dim shared as long intl_on = TRUE

extern "C"
/':::::'/
sub fb_I18nSet FBCALL ( on_off as long )
    intl_on = on_off <> 0
end sub

/':::::'/
function fb_I18nGet FBCALL ( ) as long
    return intl_on
end function
end extern