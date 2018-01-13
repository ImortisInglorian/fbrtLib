/' file device '/

#include "fb.bi"

dim shared as FB_FILE_HOOKS hooks_dev_err = ( _
    @fb_DevFileEof, _
    @fb_DevStdIoClose, _
    NULL, _
    NULL, _
    @fb_DevFileRead, _
    @fb_DevFileReadWstr, _ 
    @fb_DevFileWrite, _
    @fb_DevFileWriteWstr, _
    NULL, _
    NULL, _
    @fb_DevFileReadLine, _
    @fb_DevFileReadLineWstr, _
    NULL, _
    NULL)

extern "C"
function fb_DevErrOpen( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
    dim as long res = fb_ErrorSetNum( FB_RTERROR_OK )

    FB_LOCK()

    handle->hooks = @hooks_dev_err

    if ( handle->access = FB_FILE_ACCESS_ANY ) then
        handle->access = FB_FILE_ACCESS_READWRITE
	end if

    if ( res = FB_RTERROR_OK ) then
        handle->opaque = stderr
        handle->type = FB_FILE_TYPE_PIPE
    end if

    FB_UNLOCK()

	return res
end function
end extern