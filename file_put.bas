/' put # function '/

#include "fb.bi"

extern "C"
function fb_FilePutDataEx _
	( _
		handle as FB_FILE ptr, _
		_pos as fb_off_t, _
		_data as any const ptr, _
		length as size_t, _
		adjust_rec_pos as long, _
		checknewline as long, _
		is_unicode as long ) as long
	dim as long res

    if ( FB_HANDLE_USED(handle) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if ( _pos < 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    FB_LOCK()

    res = fb_ErrorSetNum( FB_RTERROR_OK )

    /' clear put back buffer for every modifying non-read operation '/
    handle->putback_size = 0

    /' seek to newpos '/
    if ( _pos > 0 ) then
        res = fb_FileSeekEx( handle, _pos )
	end if

    if (res = FB_RTERROR_OK) then
        /' do write '/
        if ( is_unicode = 0 ) then
        	if ( handle->hooks->pfnWrite <> NULL ) then
            	res = handle->hooks->pfnWrite( handle, _data, length )
        	else
            	res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if
        else
        	if ( handle->hooks->pfnWriteWstr <> NULL ) then
            	res = handle->hooks->pfnWriteWstr( handle, cast(FB_WCHAR ptr, _data), length )
        	else
            	res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
			end if
        end if

    end if

    if ( handle->mode = FB_FILE_MODE_RANDOM and _
    	res = FB_RTERROR_OK and _
    	adjust_rec_pos <> 0 and _
        handle->len <> 0 and _
        handle->hooks->pfnSeek <> NULL ) then
        /' if in random mode, writes must be of reclen.
         * The device must also support the SEEK method and the length
         * must be non-null '/

		if ( length <> cast(size_t, handle->len) ) then
			res = fb_ErrorSetNum( FB_RTERROR_FILEIO )
		end if

        dim as size_t skip_size = (handle->len - _
        				   (iif(is_unicode = 0, length, length * sizeof( FB_WCHAR )) mod handle->len)) mod handle->len
        if (skip_size <> 0) then
            /' devices that don't support seek should simulate it
             with write or never allow to be opened for random access '/
            handle->hooks->pfnSeek( handle, skip_size, SEEK_CUR )
        end if
    end if

#ifndef FB_NATIVE_TAB
    if ( checknewline <> 0 ) then
    	if ( res = FB_RTERROR_OK ) then
    		dim as size_t i = length
    		if ( is_unicode = 0 ) then
    			dim as ubyte const ptr pachText = cast(ubyte const ptr, _data)

        		/' search for last printed CR or LF '/
				i -= 1
        		while (i)
            		dim as ubyte ch = pachText[i]
            		if ( ch = asc(!"\n") or ch = asc(!"\r") ) then
	                	exit while
					end if
					i -= 1
        		wend
        	else
    			dim as FB_WCHAR const ptr pachText = cast(FB_WCHAR const ptr, _data)

        		/' search for last printed CR or LF '/
				i -= 1
        		while (i)
            		dim as FB_WCHAR ch = pachText[i]
            		if ( ch = asc(!"\n") or ch = asc(!"\r") ) then
	                	exit while
					end if
					i -= 1
        		wend

        	end if

	       	handle = FB_HANDLE_DEREF(handle)
        	i += 1
        	if (i = 0) then
	            handle->line_length += length
    	    else
        	    handle->line_length = length - i
			end if

        	scope
            	dim as long iWidth = FB_HANDLE_DEREF(handle)->width
            	if ( iWidth <> 0 ) then
                	handle->line_length mod= iWidth
            	end if
        	end scope
    	end if
	end if
#endif

	FB_UNLOCK()

	/' set the error code again - handle->hooks->pfnSeek() may have reset it '/
	return fb_ErrorSetNum( res )
end function

function fb_FilePutData _
	( _
		fnum as long, _
		_pos as fb_off_t, _
		_data as any const ptr, _
		length as size_t, _
		adjust_rec_pos as long, _
		checknewline as long _
	) as long
    return fb_FilePutDataEx( FB_FILE_TO_HANDLE(fnum),_
    						 _pos, _data, length, adjust_rec_pos, checknewline, FALSE )
end function

function fb_FilePut FBCALL _
	( _
		fnum as long, _
		_pos as long, _
		value as any ptr, _
		valuelen as size_t _
	) as long
	return fb_FilePutData( fnum, _pos, value, valuelen, TRUE, FALSE )
end function

function fb_FilePutLarge FBCALL _
	( _
		fnum as long, _
		_pos as longint, _
		value as any ptr, _
		valuelen as size_t _
	) as long
	return fb_FilePutData( fnum, _pos, value, valuelen, TRUE, FALSE )
end function
end extern