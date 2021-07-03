/' print functions '/

#include "fb.bi"

#define FB_PRINT_BUFFER_SIZE 2048

extern "C"
private sub fb_hPrintPadEx( handle as FB_FILE ptr, mask as long, current_x as long, new_x as long )
#ifdef FB_NATIVE_TAB
    FB_PRINT_EX(handle, !"\t", 1, mask)
#else
    dim as ubyte tab_char_buffer(0 to FB_TAB_WIDTH)
    if (new_x <= current_x) then
        FB_PRINT_EX(handle, sadd(FB_NEWLINE), sizeof(FB_NEWLINE)-1, mask)
    else
        dim as size_t count = new_x - current_x
        memset(@tab_char_buffer(0), 32, count)
        /' the terminating NUL shouldn't be required but it makes
         * debugging easier '/
        tab_char_buffer(count) = 0
        FB_PRINT_EX(handle, @tab_char_buffer(0), count, mask)
    end if
#endif
end sub

/':::::'/
sub fb_PrintPadEx ( handle as FB_FILE ptr, mask as long )
#ifdef FB_NATIVE_TAB
    FB_PRINT_EX(handle, !"\t", 1, mask)

#else
    dim as FB_FILE ptr tmp_handle
   	dim as long old_x
    dim as long new_x

    fb_DevScrnInit_Write( )

    tmp_handle = FB_HANDLE_DEREF(handle)

    old_x = tmp_handle->line_length + 1
    new_x = old_x + FB_TAB_WIDTH - 1
    new_x /= FB_TAB_WIDTH
    new_x *= FB_TAB_WIDTH
    new_x += 1
    if (tmp_handle->width <> 0) then
        /' If padding moved us beyond EOL, move to beginning of next line '/
        if (new_x > cast(long,tmp_handle->width)) then
            new_x = 1
        end if
    end if
    fb_hPrintPadEx(handle, mask, old_x, new_x)
#endif
end sub

/':::::'/
sub fb_PrintPad FBCALL ( fnum as long, mask as long )
    fb_PrintPadEx( FB_FILE_TO_HANDLE(fnum), mask )
end sub
end extern