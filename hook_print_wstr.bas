/' print wstring entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintBufferWstrEx FBCALL ( buffer as const FB_WCHAR ptr, _len as size_t, mask as long )
	FB_LOCK()

    if ( __fb_ctx.hooks.printbuffwproc <> NULL ) then
        __fb_ctx.hooks.printbuffwproc( buffer, _len, mask )
    else
        fb_ConsolePrintBufferWstrEx( buffer, _len, mask )
	end if

	FB_UNLOCK()

end sub

/':::::'/
sub fb_PrintBufferWstr FBCALL ( buffer as const FB_WCHAR ptr, mask as long )
    fb_PrintBufferWstrEx( buffer, fb_wstr_Len( buffer ), mask )
end sub
end extern