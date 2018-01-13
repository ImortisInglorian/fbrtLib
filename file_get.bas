/' get # function '/

#include "fb.bi"

extern "C"
function fb_FileGetDataEx ( handle as FB_FILE ptr, _pos as fb_off_t, dst as any ptr, length as size_t, bytesread as size_t ptr, adjust_rec_pos as long, is_unicode as long ) as long
    dim as long res
    dim as size_t chars, read_chars
    dim as ubyte ptr pachData = cast(ubyte ptr, dst)

	if ( bytesread <> 0 ) then
		*bytesread = 0
	end if

    if ( FB_HANDLE_USED(handle) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if ( _pos < 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    FB_LOCK()

    res = fb_ErrorSetNum( FB_RTERROR_OK )

    chars = length

    /' seek to newpos '/
    if ( _pos > 0 ) then
        res = fb_FileSeekEx( handle, _pos )
	end if

    /' any data in the put-back buffer? '/
    if ( handle->putback_size <> 0 ) then
        dim as size_t bytes, _len
    	dim as FB_WCHAR ptr wcp
    	dim as ubyte ptr cp

        bytes = chars
        if ( handle->encod <> FB_FILE_ENCOD_ASCII ) then
        	bytes *= sizeof( FB_WCHAR )
		end if

        bytes = iif(handle->putback_size >= bytes, bytes, handle->putback_size)

        if ( is_unicode = 0 ) then
        	if ( handle->encod = FB_FILE_ENCOD_ASCII ) then
        		memcpy( pachData, @handle->putback_buffer(0), bytes )
        	else
        		cp = pachData
        		wcp = cast(FB_WCHAR ptr, @handle->putback_buffer(0))
        		_len = bytes
        		while ( _len > 0 )
        			cp[1] = wcp[1]
        			_len -= sizeof( FB_WCHAR )
        		wend
        	end if
        else
        	if ( handle->encod <> FB_FILE_ENCOD_ASCII ) then
        		memcpy( pachData, @handle->putback_buffer(0), bytes )
        	else
        		cp = pachData
        		wcp = cast(FB_WCHAR ptr, @handle->putback_buffer(0))
        		_len = bytes
        		while( _len - 1 > 0 )
        			wcp[1] = cp[1]
				wend
        	end if
        end if

        handle->putback_size -= bytes
        if ( handle->putback_size <> 0 ) then
            memmove( @handle->putback_buffer(0), @handle->putback_buffer(0) + bytes, handle->putback_size )
		end if

        pachData += bytes

        if ( handle->encod <> FB_FILE_ENCOD_ASCII ) then
        	bytes /= sizeof( FB_WCHAR )
		end if

        read_chars = bytes
        chars -= bytes
    else
    	read_chars = 0
	end if

    if ( (res = FB_RTERROR_OK) and (chars <> 0) ) then
        /' do read '/
        if ( is_unicode = 0 ) then
        	if ( handle->hooks->pfnRead = NULL ) then
            	res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        	else
        		res = handle->hooks->pfnRead( handle, pachData, @chars )
        		read_chars += chars
        	end if
        else
        	if ( handle->hooks->pfnReadWstr = NULL ) then
            	res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
        	else
        		res = handle->hooks->pfnReadWstr( handle, cast(FB_WCHAR ptr, pachData), @chars )
        		read_chars += chars
        	end if
        end if
    end if

    if ( handle->mode = FB_FILE_MODE_RANDOM and _
        res = FB_RTERROR_OK and _
        adjust_rec_pos <> 0 and _
        handle->len <> 0 and _
        handle->hooks->pfnSeek <> NULL ) then
        /' if in random mode, reads must be of reclen.
         * The device must also support the SEEK method and the length
         * must be non-null '/

		if ( length <> cast(size_t, handle->len) ) then
			res = fb_ErrorSetNum( FB_RTERROR_FILEIO )
		end if


		dim as size_t skip_size = (handle->len - _
        				   (iif(is_unicode = 0, read_chars, read_chars*sizeof( FB_WCHAR )) mod handle->len)) mod handle->len

        if ( skip_size <> 0 ) then
            /' don't forget the put back buffer '/
            if ( skip_size > handle->putback_size ) then
                skip_size -= handle->putback_size
                handle->putback_size = 0
            else
                handle->putback_size -= skip_size
                skip_size = 0
            end if
        end if

        if ( skip_size <> 0) then
            /' devices that don't support seek should simulate it
             with read or never allow to be opened for random access '/
            handle->hooks->pfnSeek( handle, skip_size, SEEK_CUR )
        end if
    end if

	if ( bytesread <> 0 ) then
		*bytesread = read_chars
	end if

	FB_UNLOCK()

	/' set the error code again - handle->hooks->pfnSeek() may have reset it '/
	return fb_ErrorSetNum( res )
end function

/':::::'/
/' Can fb_FileGetData() be removed? it's not used by the rtlib
 * nor is it referenced by fbc?  Compatibility with old libs? [jeffm]
 '/
function fb_FileGetData( fnum as long, _pos as fb_off_t, dst as any ptr, chars as size_t, adjust_rec_pos as long ) as long
    return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _
    						 _pos, _
    						 dst, _
    						 chars, _
							 NULL, _
    						 adjust_rec_pos, _
    						 FALSE )
end function

function fb_FileGet FBCALL ( fnum as long, _pos as long, dst as any ptr, chars as size_t ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _
							 _pos, _
							 dst, _
							 chars, _
							 NULL, _
							 TRUE, _
							 FALSE )
end function

function fb_FileGetLarge FBCALL ( fnum as long, _pos as longint, dst as any ptr, chars as size_t ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _
							 _pos, _
							 dst, _
							 chars, _
							 NULL, _
							 TRUE, _
							 FALSE )
end function

function fb_FileGetIOB FBCALL ( fnum as long, _pos as long, dst as any ptr, chars as size_t, bytesread as size_t ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _
							 _pos, _
							 dst, _
							 chars, _
							 bytesread, _
							 TRUE, _
							 FALSE )
end function

function fb_FileGetLargeIOB FBCALL ( fnum as long, _pos as longint, dst as any ptr, chars as size_t, bytesread as size_t ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _
							 _pos, _
							 dst, _
							 chars, _
							 bytesread, _
							 TRUE, _
							 FALSE )
end function
end extern