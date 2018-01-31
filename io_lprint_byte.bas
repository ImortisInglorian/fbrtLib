/' print [#] function (byte) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintByte FBCALL ( fnum as long, _val as ubyte, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, cast(long, _val), mask, "% ", "d" )
end sub

/':::::'/
sub fb_LPrintUByte FBCALL ( fnum as long, _val as ubyte, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, cast(ulong, _val), mask, "%", "u" )
end sub
end extern