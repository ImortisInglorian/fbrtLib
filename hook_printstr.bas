/' print string entrypoint, default to console mode '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_PrintBufferEx FBCALL ( buffer as any const ptr, _len as size_t, mask as long )
	FB_LOCK()

    if ( __fb_ctx.hooks.printbuffproc <> NULL ) then
        __fb_ctx.hooks.printbuffproc( buffer, _len, mask )
    else
        fb_ConsolePrintBufferEx( buffer, _len, mask )
	end if

	FB_UNLOCK()
end sub

/':::::'/
sub fb_PrintBuffer FBCALL ( buffer as ubyte const ptr, mask as long )
    fb_PrintBufferEx( buffer, strlen( buffer ), mask )
end sub
end extern