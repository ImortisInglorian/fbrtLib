/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnReadWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
    dim as size_t chars, copy_chars
    dim as DEV_SCRN_INFO ptr info

    /' !!!FIXME!!! no unicode input supported '/

    FB_LOCK()

    chars = *pchars

    info = cast(DEV_SCRN_INFO ptr, FB_HANDLE_DEREF(handle)->opaque)

    while ( chars > 0 )
        dim as size_t _len = info->length / sizeof( FB_WCHAR )
        copy_chars = iif(chars > _len, _len, chars)
        if ( copy_chars = 0 ) then
        	while ( fb_KeyHit( ) = 0 )
           		fb_Delay( 25 )				/' release time slice '/
			wend

            fb_DevScrnFillInput( info )
            if ( info->length <> 0 ) then
                continue while
			end if
			
            exit while
        end if

        fb_wstr_ConvFromA( dst, chars, @info->buffer(0) )

        info->length -= copy_chars * sizeof( FB_WCHAR )
        if ( info->length <> 0 ) then
            memmove( @info->buffer(0), @info->buffer(copy_chars * sizeof( FB_WCHAR )),info->length )
        end if

        chars -= copy_chars
        dst += copy_chars
    wend

    FB_UNLOCK()

    if ( chars <> 0 ) then
        memset( dst, 0, chars * sizeof( FB_WCHAR ) )
	end if

    *pchars -= chars

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

private function hReadFromStdin( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
    return fb_DevFileReadWstr( NULL, dst, pchars )
end function

sub fb_DevScrnInit_ReadWstr( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if ( FB_HANDLE_SCREEN->hooks->pfnReadWstr = NULL ) then
    	FB_HANDLE_SCREEN->hooks->pfnReadWstr = iif(fb_IsRedirected( TRUE ), @hReadFromStdin, @fb_DevScrnReadWstr)
	end if
	
	FB_UNLOCK( )
end sub
end extern