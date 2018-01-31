/' print [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintWstr FBCALL ( fnum as long, s as FB_WCHAR const ptr, mask as long )
    fb_LPrintInit()

    fb_PrintWstrEx( FB_FILE_TO_HANDLE(fnum), s, FB_PRINT_CONVERT_BIN_NEWLINE(mask) )
end sub
end extern