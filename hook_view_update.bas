/' call back function that gets called whenever VIEW PRINT was called '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_ViewUpdate FBCALL ( )
    FB_LOCK()

    if ( @__fb_ctx.hooks.viewupdateproc <> NULL ) then
        __fb_ctx.hooks.viewupdateproc( )
    else
        fb_ConsoleViewUpdate( )
    end if

    FB_UNLOCK()
end sub
end extern