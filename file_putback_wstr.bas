/' ungetwc-like function '/

#include "fb.bi"

extern "C"
function fb_FilePutBackWstrEx( handle as FB_FILE ptr, src as FB_WCHAR ptr, chars as size_t ) as long
	dim as long res
	dim as size_t bytes
    dim as ubyte ptr dst

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    FB_LOCK()

    res = fb_ErrorSetNum( FB_RTERROR_OK )

    /' UTF? '/
    if ( handle->encod <> FB_FILE_ENCOD_ASCII ) then
    	bytes = chars * sizeof( FB_WCHAR )
    else
    	bytes = chars
	end if

    if ( handle->putback_size + bytes > ARRAY_SIZEOF(handle->putback_buffer) ) then
        res = fb_ErrorSetNum( FB_RTERROR_FILEIO )
    else
        if ( handle->putback_size <> 0 ) then
            memmove( @handle->putback_buffer(0) + bytes, _
                     @handle->putback_buffer(0), _
                     handle->putback_size )
		end if
        handle->putback_size += bytes

        /' note: if encoding != ASCII, putback buffer will be in
           wchar format, not in UTF '/
        if ( handle->encod <> FB_FILE_ENCOD_ASCII ) then
        	memcpy( @handle->putback_buffer(0), src, bytes )
        else
        	/' wchar to char '/
        	dst = @handle->putback_buffer(0)
			chars -= 1
        	while( chars > 0 )
				dst += 1
				src += 1
        		*dst = *src
				chars -= 1
			wend
        end if
    end if

	FB_UNLOCK()

	return res
end function

function fb_FilePutBackWstr FBCALL ( fnum as long, src as FB_WCHAR const ptr, chars as size_t ) as long
    return fb_FilePutBackWstrEx( FB_FILE_TO_HANDLE(fnum), src, chars )
end function
end extern