/' print [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintFixString FBCALL ( fnum as long, s as ubyte const ptr, mask as long )
    fb_LPrintInit()
    fb_PrintFixStringEx(FB_FILE_TO_HANDLE(fnum), s, FB_PRINT_CONVERT_BIN_NEWLINE(mask))
end sub
end extern