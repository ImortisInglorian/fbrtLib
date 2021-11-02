/' input function '/

#include "fb.bi"
#include "fb_private_thread.bi"
#include "fb_private_file.bi"

extern "C"
function fb_FileInput FBCALL ( fnum as long ) as long
    dim as FB_INPUTCTX ptr ctx
    dim as FB_FILE ptr handle = NULL

	FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)
    if ( FB_HANDLE_USED(handle) = 0 ) then
        FB_UNLOCK()
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    ctx = fb_get_thread_inputctx( )

    ctx->handle = handle
    ctx->status = 0
    fb_StrDelete( cast(FBSTRING ptr, @ctx->str) )
    ctx->index	= 0

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

end extern

private sub INPUTCTX_destructor( byval _data as any ptr )

    dim as FB_INPUTCTX ptr ctx = cast( FB_INPUTCTX ptr, _data )
    fb_StrDelete( @ctx->str )
    Delete ctx
    /' The file handle is closed by the program, it's not ours to clean up '/

end sub

function fb_get_thread_inputctx( ) as FB_INPUTCTX ptr
    dim thread As FBThread Ptr = fb_GetCurrentThread( )
    dim ctx As FB_INPUTCTX ptr = cast( FB_INPUTCTX ptr, thread->GetData( FB_TLSKEY_INPUT ) )
    If( ctx = Null ) Then
        ctx = New FB_INPUTCTX
        thread->SetData( FB_TLSKEY_INPUT, ctx, @INPUTCTX_destructor )
    End If
    Return ctx

end function
