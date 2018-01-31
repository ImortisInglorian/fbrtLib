/' print [#] function (boolean) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintBool FBCALL ( fnum as long, _val as ubyte, mask as long )
    FB_PRINTNUM( fnum, fb_hBoolToStr( _val ), mask, "%", "s" )
end sub
end extern