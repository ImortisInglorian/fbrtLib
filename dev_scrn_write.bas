/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnWrite( handle as FB_FILE ptr, value as any const ptr, valuelen as size_t ) as long
    fb_PrintBufferEx( value, valuelen, 0 )
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

sub fb_DevScrnInit_Write( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if( FB_HANDLE_SCREEN->hooks->pfnWrite = NULL ) then
    	FB_HANDLE_SCREEN->hooks->pfnWrite = @fb_DevScrnWrite
	end if
	FB_UNLOCK( )
end sub
end extern