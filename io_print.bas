/' print [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
private sub fb_hPrintStrEx( handle as FB_FILE ptr, s as const ubyte ptr, _len as size_t, mask as long )
    /' add a lock here or the new-line won't be printed in the right
       place if PRINT is been used in multiple threads and a context
       switch happens between FB_PRINT_EX() and PrintVoidEx() '/
    FB_LOCK( )

    if ( _len <> 0 ) then
        FB_PRINT_EX(handle, s, _len, 0)
	end if

    fb_PrintVoidEx( handle, mask )

    FB_UNLOCK( )
end sub

/':::::'/
sub fb_PrintStringEx( handle as FB_FILE ptr, s as FBSTRING ptr, mask as long )
    if ( (s = NULL) or (s->data = NULL) ) then
    	fb_PrintVoidEx( handle, mask )
    else
    	fb_hPrintStrEx( handle, s->data, FB_STRSIZE(s), mask )
	end if
end sub

/':::::'/
sub fb_PrintString FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
    fb_PrintStringEx(FB_FILE_TO_HANDLE(fnum), s, mask)
end sub
end extern