/' file device '/

#include "fb.bi"

extern "C"
private function hWrapper( buffer as ubyte ptr, count as size_t, fp as FILE ptr ) as ubyte ptr
    return fgets( buffer, count, fp )
end function

function fb_DevFileReadLineDumb ( fp as FILE ptr, dst as FBSTRING ptr, pfnReadString as fb_FnDevReadString ) as long
    dim as long res = fb_ErrorSetNum( FB_RTERROR_OK )
    dim as size_t buffer_len
    dim as long found, first_run
    dim as ubyte ptr buffer(0 to 511)
    dim as FBSTRING src = ( buffer(0), 0, 0 )

    DBG_ASSERT( dst <> NULL )

    buffer_len = sizeof(buffer)
    first_run = TRUE

	FB_LOCK()

	if ( pfnReadString = NULL ) then
		pfnReadString = @hWrapper
	end if
    
    found = FALSE
    while (found = FALSE )
        memset( @buffer(0), 0, buffer_len )

        if( pfnReadString( buffer(0), sizeof( buffer ), fp ) = NULL ) then
            /' EOF reached ... this is not an error !!! '/
            res = FB_RTERROR_ENDOFFILE /' but we have to notify the caller '/

            if ( first_run ) then
            	fb_StrDelete( dst )
			end if

            exit while
        end if

        /' the last character always is NUL '/
        buffer_len = sizeof(buffer) - 1

        /' now let's find the end of the buffer '/
		buffer_len -= 1
        while (buffer_len <> 0)
            dim as ubyte ptr ch = buffer(buffer_len)
            if (ch = asc(!"\n") or ch = asc(!"\r")) then
                /' accept both CR and LF '/
                found = TRUE
                exit while
            elseif ( ch <> 0 ) then
                /' a character other than CR/LF found ... i.e. buffer full '/
                exit while
            end if
        wend

        dim as ssize_t tmp_buf_len
        
        if ( found = FALSE ) then
            /' remember the real length '/
			buffer_len += 1
            tmp_buf_len = buffer_len

            /' not found ... so simply add this to the result string '/
        else
            /' remember the real length '/
            tmp_buf_len = buffer_len + 1

            /' filter a (possibly valid) CR/LF sequence '/
            if ( buffer(buffer_len) = asc(!"\n") and buffer_len <> 0 ) then
                if ( buffer(buffer_len-1) = asc(!"\r") ) then
                    buffer_len -= 1
                end if
            end if

            /' set the CR or LF to NUL '/
            buffer(buffer_len) = 0
        end if
		
		src.len = buffer_len
        src.size = src.len

        /' assign or concatenate '/
        if ( first_run <> 0 ) then
        	fb_StrAssign( dst, -1, @src, -1, FALSE )
        else
        	fb_StrConcatAssign( dst, -1, @src, -1, FALSE )
		end if

        first_run = FALSE

        buffer_len = tmp_buf_len
    wend

	FB_UNLOCK()

	return res

end function

function fb_DevFileReadLine( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
    dim as long res
    dim as FILE ptr fp

	FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)
    if ( fp = stdout or fp = stderr ) then
        fp = stdin
	end if

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    res = fb_DevFileReadLineDumb( fp, dst, NULL )

	FB_UNLOCK()

	return res
end function
end extern