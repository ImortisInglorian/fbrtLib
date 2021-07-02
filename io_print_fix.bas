/' print [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
private sub fb_hPrintStrEx( handle as FB_FILE ptr, s as const ubyte ptr, _len as size_t, mask as long )
    if ( _len <> 0 ) then
        FB_PRINT_EX(handle, s, _len, 0)
    end if

    fb_PrintVoidEx( handle, mask )
end sub

/':::::'/
sub fb_PrintFixStringEx ( handle as FB_FILE ptr, s as const ubyte ptr, mask as long )
    if ( s = NULL ) then
    	fb_PrintVoidEx( handle, mask )
    else
    	fb_hPrintStrEx( handle, s, strlen( s ), mask )
	end if
end sub

/':::::'/
sub fb_PrintFixString FBCALL ( fnum as long, s as const ubyte ptr, mask as long )
    fb_PrintFixStringEx(FB_FILE_TO_HANDLE(fnum), s, mask)
end sub
end extern