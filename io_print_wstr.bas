/' print [#] wstring functions '/

#include "fb.bi"

extern "C"
/':::::'/
private sub fb_hPrintWstrEx( handle as FB_FILE ptr, s as FB_WCHAR const ptr, _len as size_t, mask as long )
    /' add a lock here or the new-line won't be printed in the right
       place if PRINT is been used in multiple threads and a context
       switch happens between FB_PRINT_EX() and PrintVoidEx() '/
    FB_LOCK( )

    if ( _len <> 0 ) then
        FB_PRINTWSTR_EX( handle, s, _len, 0 )
	end if

    fb_PrintVoidWstrEx( handle, mask )

    FB_UNLOCK( )
end sub

/':::::'/
sub fb_PrintWstrEx( handle as FB_FILE ptr, s as FB_WCHAR const ptr, mask as long )
    if ( s = NULL ) then
    	fb_PrintVoidWstrEx( handle, mask )
    else
    	fb_hPrintWstrEx( handle, s, fb_wstr_Len( s ), mask )
	end if
end sub

/':::::'/
sub fb_PrintWstr FBCALL ( fnum as long, s as FB_WCHAR const ptr, mask as long )
    fb_PrintWstrEx(FB_FILE_TO_HANDLE(fnum), s, mask)
end sub
end extern