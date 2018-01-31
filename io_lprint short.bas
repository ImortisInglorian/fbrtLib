/' print [#] function (short) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintShort FBCALL ( fnum as long, _val as short, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, _val, mask, "% ", "hd" )
end sub

/':::::'/
sub fb_LPrintUShort FBCALL ( fnum as long, _val as ushort, mask as long)
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, _val, mask, "%", "hu" )
end sub
end extern