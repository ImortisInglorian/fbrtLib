/' print functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintVoidWstrEx( handle as FB_FILE ptr, mask as long )
    if ( mask and FB_PRINT_BIN_NEWLINE ) then
        FB_PRINTWSTR_EX( handle, @FB_BINARY_NEWLINE_WSTR, sizeof( FB_BINARY_NEWLINE_WSTR ) / sizeof( FB_WCHAR ) - 1, mask )
    elseif ( mask and FB_PRINT_NEWLINE ) then
        FB_PRINTWSTR_EX( handle, @FB_NEWLINE_WSTR, sizeof( FB_NEWLINE_WSTR ) / sizeof( FB_WCHAR ) - 1, mask )
    elseif ( mask and FB_PRINT_PAD ) then
        fb_PrintPadWstrEx( handle, mask and not(FB_PRINT_HLMASK) )
    end if
end sub

/':::::'/
sub fb_PrintVoidWstr FBCALL ( fnum as long , mask as long )
    fb_PrintVoidWstrEx( FB_FILE_TO_HANDLE(fnum), mask )
end sub
end extern