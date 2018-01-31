/' print [#] function (boolean) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintBool FBCALL ( fnum as long, _val as ubyte, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, fb_hBoolToStr( _val ), mask, "%", "s" )
end sub
end extern