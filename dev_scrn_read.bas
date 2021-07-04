/' file device '/

#include "fb.bi"

extern "C"
function fb_DevScrnRead( handle as FB_FILE ptr, value as any ptr, pLength as size_t ptr ) as long
    dim as size_t length, copy_length
    dim as DEV_SCRN_INFO ptr info
    dim as ubyte ptr pachBuffer = cast(ubyte ptr, value)

    FB_LOCK()

    DBG_ASSERT(pLength <> NULL)
    length = *pLength

    info = cast(DEV_SCRN_INFO ptr, FB_HANDLE_DEREF(handle)->opaque)

    while ( length > 0 )
        copy_length = iif(length > info->length, info->length, length)
        if (copy_length = 0) then

        	while( fb_KeyHit( ) = 0 )
           		fb_Delay( 25 )				/' release time slice '/
			wend

            fb_DevScrnFillInput( info )
            if ( info->length <> 0 ) then
                continue while
			end if

            exit while
        end if
        memcpy(pachBuffer, @info->buffer(0), copy_length)
        info->length -= copy_length
        if (info->length <> 0) then
            memmove(@info->buffer(0), @info->buffer(copy_length), info->length)
        end if
        length -= copy_length
        pachBuffer += copy_length
    wend

    FB_UNLOCK()

    if (length <> 0) then
        memset(pachBuffer, 0, length)
	end if

    *pLength -= length

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function 

private function hReadFromStdin( handle as FB_FILE ptr, dst as any ptr, pLength as size_t ptr ) as long
    return fb_DevFileRead( NULL, dst, pLength )
end function

sub fb_DevScrnInit_Read( )
	fb_DevScrnInit_NoOpen( )

	FB_LOCK( )
    if ( FB_HANDLE_SCREEN->hooks->pfnRead = NULL ) then
    	FB_HANDLE_SCREEN->hooks->pfnRead = iif(fb_IsRedirected( TRUE ), @hReadFromStdin, @fb_DevScrnRead)
    end if
	FB_UNLOCK( )
end sub
end extern