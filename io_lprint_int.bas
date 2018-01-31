/' print [#] function (int) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintInt FBCALL ( fnum as long, _val as long, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, _val, mask, "% ", "d" )
end sub

/':::::'/
sub fb_LPrintUInt FBCALL ( fnum as long, _val as ulong, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, _val, mask, "%", "u" )
end sub
end extern