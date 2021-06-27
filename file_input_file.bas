/' input function '/

#include "fb.bi"

extern "C"
function fb_FileInput FBCALL ( fnum as long ) as long
    dim as FB_INPUTCTX ptr ctx
    dim as FB_FILE ptr handle = NULL

	FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)
    if ( FB_HANDLE_USED(handle) = NULL ) then
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    ctx = _FB_TLSGETCTX( INPUT )

    ctx->handle = handle
    ctx->status = 0
    fb_StrDelete( cast(FBSTRING ptr, @ctx->str) )
    ctx->index	= 0

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

sub fb_INPUTCTX_Destructor( byval _data as any ptr )

    dim as FB_INPUTCTX ptr ctx = cast( FB_INPUTCTX ptr, _data )
    fb_StrDelete( @ctx->str )
    /' The file handle is closed by the program, it's not ours to clean up '/

end sub

end extern