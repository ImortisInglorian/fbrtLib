/' RESET function '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_FileReset FBCALL ( )
	dim as long i

	if ( __fb_ctx.do_file_reset = FALSE ) then
		exit sub
	end if

	__fb_ctx.do_file_reset = FALSE

    FB_LOCK()

    for i = 1 to (FB_MAX_FILES - FB_RESERVED_FILES) 
        dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE_VALID( i )
        if ( handle->hooks <> NULL ) then
            DBG_ASSERT(handle->hooks->pfnClose <> NULL)
            handle->hooks->pfnClose( handle )
        end if
    next
    
	/' clear all file handles '/
    memset( FB_FILE_TO_HANDLE_VALID( 1 ), _
            0, _
            sizeof(FB_FILE) * (FB_MAX_FILES - FB_RESERVED_FILES) )

    FB_UNLOCK()
end sub
end extern