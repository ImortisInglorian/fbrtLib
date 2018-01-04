/' file device '/

#include "fb.bi"

dim shared as FB_FILE_HOOKS hooks_dev_scrn_null = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )

extern "C"
/' Update width/line_length after the screen was resized (can happen with
   console/terminal windows but also with graphics window) '/
sub fb_DevScrnUpdateWidth( ) 
	dim as long cols
	fb_GetSize( @cols, NULL )
	FB_HANDLE_SCREEN.line_length = fb_GetX( ) - 1
	FB_HANDLE_SCREEN.width = cols
end sub

sub fb_DevScrnMaybeUpdateWidth( )
	/' Only if it was initialized (i.e. used) yet, otherwise we don't need
	   to bother '/
	if ( FB_HANDLE_SCREEN.hooks ) then
		fb_DevScrnUpdateWidth( )
	end if
end sub


sub fb_DevScrnInit_Screen( )
	fb_DevScrnUpdateWidth( )
	FB_HANDLE_SCREEN.opaque = calloc(1, sizeof(DEV_SCRN_INFO))
end sub

sub fb_DevScrnEnd( handle as FB_FILE ptr )
	if ( handle->opaque ) then
		free( handle->opaque )
		handle->opaque = NULL
	end if
end sub

sub fb_DevScrnInit_NoOpen( )
	FB_LOCK()
    if ( FB_HANDLE_SCREEN.hooks = NULL ) then
        memset(@FB_HANDLE_SCREEN, 0, sizeof(FB_HANDLE_SCREEN))

        FB_HANDLE_SCREEN.mode = FB_FILE_MODE_APPEND
        FB_HANDLE_SCREEN.type = FB_FILE_TYPE_VFS
        FB_HANDLE_SCREEN.access = FB_FILE_ACCESS_READWRITE

        fb_DevScrnInit_Screen( )

        FB_HANDLE_SCREEN.hooks = @hooks_dev_scrn_null
    end if
	FB_UNLOCK()
end sub
end extern