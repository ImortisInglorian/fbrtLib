/' print [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_LPrintString FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
    fb_LPrintInit()
    fb_PrintStringEx(FB_FILE_TO_HANDLE(fnum), s, FB_PRINT_CONVERT_BIN_NEWLINE(mask) )
end sub
end extern
