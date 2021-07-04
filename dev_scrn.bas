/' file device '/

#include "fb.bi"

extern "C"
dim shared as FB_FILE_HOOKS hooks_dev_scrn = ( _
    @fb_DevScrnEof, _
    @fb_DevScrnClose, _
    NULL, _
    NULL, _
    @fb_DevScrnRead, _
    @fb_DevScrnReadWstr, _ 
    @fb_DevScrnWrite, _
    @fb_DevScrnWriteWstr, _
    NULL, _
    NULL, _
    @fb_DevScrnReadLine, _
    @fb_DevScrnReadLineWstr, _
    NULL, _
    NULL )

function fb_DevScrnOpen( handle as FB_FILE ptr, filename as const ubyte ptr, filename_len as size_t ) as long
    FB_LOCK()

    if (handle <> FB_HANDLE_SCREEN) then
        /' Duplicate and copy the DEV_SCRN_INFO from FB_HANDLE_SCREEN '/
        dim as DEV_SCRN_INFO ptr _screeninfo = cast(DEV_SCRN_INFO ptr, FB_HANDLE_SCREEN->opaque)
        dim as DEV_SCRN_INFO ptr info = malloc(sizeof(DEV_SCRN_INFO))
        memcpy(info, _screeninfo, sizeof(DEV_SCRN_INFO))
        handle->opaque = info

        handle->hooks = @hooks_dev_scrn
        handle->redirection_to = FB_HANDLE_SCREEN
    elseif ( handle->hooks <> @hooks_dev_scrn ) then
    	if ( handle->hooks = NULL ) then
    		fb_DevScrnInit_Screen( )
		end if
    	handle->hooks = @hooks_dev_scrn
        handle->type = FB_FILE_TYPE_CONSOLE
    end if

    FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

sub fb_DevScrnInit( )
	FB_LOCK( )
    if ( FB_HANDLE_SCREEN->hooks = NULL ) then
        memset(FB_HANDLE_SCREEN, 0, sizeof(FB_HANDLE_SCREEN))

        FB_HANDLE_SCREEN->mode = FB_FILE_MODE_APPEND
        FB_HANDLE_SCREEN->encod = FB_FILE_ENCOD_DEFAULT
        FB_HANDLE_SCREEN->type = FB_FILE_TYPE_VFS
        FB_HANDLE_SCREEN->access = FB_FILE_ACCESS_READWRITE

        fb_DevScrnOpen( FB_HANDLE_SCREEN, NULL, 0 )
    elseif ( FB_HANDLE_SCREEN->hooks <> @hooks_dev_scrn ) then
		FB_HANDLE_SCREEN->hooks = @hooks_dev_scrn
	end if
	FB_UNLOCK( )
end sub
end extern