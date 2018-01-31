/' print functions '/

#include "fb.bi"

#define FB_PRINT_BUFFER_SIZE 2048

extern "C"
private sub fb_hPrintPadWstrEx( handle as FB_FILE ptr, mask as long, current_x as long, new_x as long )
#ifdef FB_NATIVE_TAB
    FB_PRINTWSTR_EX( handle, _LC(!"\t"), 1, mask )

#else
    dim as FB_WCHAR tab_char_buffer(0 to FB_TAB_WIDTH)

    if (new_x <= current_x) then
        FB_PRINTWSTR_EX( handle, @FB_NEWLINE_WSTR, sizeof( FB_NEWLINE_WSTR ) / sizeof( FB_WCHAR ) - 1, mask )
    else
        dim as size_t i, count = new_x - current_x

        for i = 0 to count - 1
        	tab_char_buffer(i) = asc(" ")
		next

        /' the terminating NUL shouldn't be required but it makes
         * debugging easier '/
        tab_char_buffer(count) = 0

        FB_PRINTWSTR_EX( handle, @tab_char_buffer(0), count, mask )
    end if
#endif
end sub

/':::::'/
sub fb_PrintPadWstrEx( handle as FB_FILE ptr, mask as long)
#ifdef FB_NATIVE_TAB
    FB_PRINTWSTR_EX( handle, _LC(!"\t"), 1, mask )

#else
    dim as FB_FILE ptr tmp_handle
   	dim as long old_x
    dim as long new_x

    fb_DevScrnInit_WriteWstr( )

    tmp_handle = FB_HANDLE_DEREF(handle)

    old_x = tmp_handle->line_length + 1
    new_x = old_x + FB_TAB_WIDTH - 1
    new_x /= FB_TAB_WIDTH
    new_x *= FB_TAB_WIDTH
    new_x += 1
    if (tmp_handle->width <> 0) then
        dim as ulong dev_width = tmp_handle->width
        if (new_x > cast(long,(dev_width - FB_TAB_WIDTH))) then
            new_x = 1
        end if
    end if
    fb_hPrintPadWstrEx( handle, mask, old_x, new_x )
#endif
end sub

/':::::'/
sub fb_PrintPadWstr FBCALL ( fnum as long, mask as long )
    fb_PrintPadWstrEx( FB_FILE_TO_HANDLE(fnum), mask )
end sub
end extern