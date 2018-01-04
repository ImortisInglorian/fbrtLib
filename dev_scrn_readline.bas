/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnReadLine( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
    return fb_LineInput( NULL, dst, -1, FALSE, FALSE, TRUE )
end function

sub fb_DevScrnInit_ReadLine( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if ( FB_HANDLE_SCREEN.hooks->pfnReadLine = NULL ) then
        FB_HANDLE_SCREEN.hooks->pfnReadLine = @fb_DevScrnReadLine
	end if
	FB_UNLOCK( )
end sub
end extern