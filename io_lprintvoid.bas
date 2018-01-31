/' print functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintVoid FBCALL ( fnum as long, mask as long )
    fb_LPrintInit()
    fb_PrintVoidEx( FB_FILE_TO_HANDLE(fnum), FB_PRINT_CONVERT_BIN_NEWLINE(mask) )
end sub
end extern