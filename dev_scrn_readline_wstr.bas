/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnReadLineWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
    dim as long res
    dim as FBSTRING temp = ( 0, 0, 0 )

    /' !!!FIXME!!! no unicode input supported '/

    res = fb_LineInput( NULL, cast(any ptr, @temp), -1, FALSE, FALSE, TRUE )

    if ( res = FB_RTERROR_OK ) then
    	fb_WstrAssignFromA( dst, dst_chars, cast(any ptr ,@temp), -1 )
	end if

    fb_StrDelete( @temp )

    return res
end function

sub fb_DevScrnInit_ReadLineWstr( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if ( FB_HANDLE_SCREEN->hooks->pfnReadLineWstr = NULL ) then
        FB_HANDLE_SCREEN->hooks->pfnReadLineWstr = @fb_DevScrnReadLineWstr
	end if
	FB_UNLOCK( )
end sub
end extern