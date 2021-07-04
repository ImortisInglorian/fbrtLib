/' some kind of ungetc function '/

#include "fb.bi"

extern "C"
function fb_FilePutBackEx( handle as FB_FILE ptr, src as const any ptr, chars as size_t ) as long
	dim as long res
	dim as size_t bytes

    if( FB_HANDLE_USED(handle) = 0 ) then
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
        /' note: if encoding != ASCII, putback buffer will be in
           wchar format, not in UTF '/
        if ( handle->putback_size <> 0 ) then
            memmove( @handle->putback_buffer(0) + bytes, _
                     @handle->putback_buffer(0), _
                     handle->putback_size )
        end if

        if ( handle->encod = FB_FILE_ENCOD_ASCII ) then
        	memcpy( @handle->putback_buffer(0), src, bytes )
        else
    		/' char to wchar '/
    		dim as FB_WCHAR ptr dst = cast(FB_WCHAR ptr, @handle->putback_buffer(0))
    		dim as const ubyte ptr patch = cast(ubyte ptr, src)
			while( chars > 0 )
	    		*dst = *patch
				dst += 1
				patch += 1
    			chars -= 1
			wend
        end if

        handle->putback_size += bytes
    end if

	FB_UNLOCK()

	return res
end function

function fb_FilePutBack FBCALL ( fnum as long, _data as const any ptr, length as size_t ) as long
    return fb_FilePutBackEx( FB_FILE_TO_HANDLE(fnum), _data, length )
end function
end extern