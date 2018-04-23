/' sleep function '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_Sleep FBCALL ( msecs as long )
    dim as FB_SLEEPPROC sleepproc
    FB_LOCK()
    sleepproc = __fb_ctx.hooks.sleepproc
    FB_UNLOCK()
    if( @sleepproc <> NULL ) then
        sleepproc( msecs )
    else
        fb_ConsoleSleep( msecs )
    end if
end sub
end extern