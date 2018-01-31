/' print [#] function (longint) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintLongint FBCALL ( fnum as long, _val as longint, mask as long)
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
	FB_PRINTNUM( fnum, _val, mask, "% ", FB_LL_FMTMOD "d" )
end sub

/':::::'/
sub fb_LPrintULongint FBCALL ( fnum as long, _val as ulongint, mask as long )
    fb_LPrintInit()
    mask = FB_PRINT_CONVERT_BIN_NEWLINE(mask)
    FB_PRINTNUM( fnum, _val, mask, "%", FB_LL_FMTMOD "u" )
end sub
end extern