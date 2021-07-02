/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnWriteWstr( handle as FB_FILE ptr, value as FB_WCHAR const ptr, valuelen as size_t ) as long
    fb_PrintBufferWstrEx( value, valuelen, 0 )
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

sub fb_DevScrnInit_WriteWstr( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if ( FB_HANDLE_SCREEN->hooks->pfnWriteWstr = NULL ) then
    	FB_HANDLE_SCREEN->hooks->pfnWriteWstr = @fb_DevScrnWriteWstr
	end if
	FB_UNLOCK( )
end sub
end extern