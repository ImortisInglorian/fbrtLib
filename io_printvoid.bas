/' print functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintVoidEx( handle as FB_FILE ptr, mask as long )
    if ( mask and FB_PRINT_BIN_NEWLINE ) then
        FB_PRINT_EX(handle, @FB_BINARY_NEWLINE, sizeof(FB_BINARY_NEWLINE)-1, mask)
    elseif ( mask and FB_PRINT_NEWLINE ) then
        FB_PRINT_EX(handle, @FB_NEWLINE, sizeof(FB_NEWLINE)-1, mask)
    elseif ( mask and FB_PRINT_PAD ) then
        fb_PrintPadEx( handle, mask and not(FB_PRINT_HLMASK) )
    end if
end sub

/':::::'/
sub fb_PrintVoid FBCALL ( fnum as long, mask as long )
    fb_PrintVoidEx( FB_FILE_TO_HANDLE(fnum), mask )
end sub
end extern