/' input$ function '/

#include "fb.bi"

extern "C"
function fb_FileStrInput FBCALL ( bytes as ssize_t, fnum as long ) as FBSTRING ptr
    dim as FB_FILE ptr handle
	dim as FBSTRING ptr dst
    dim as size_t _len
    dim as long res = FB_RTERROR_OK

	fb_DevScrnInit_Read( )

	FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)
    if ( FB_HANDLE_USED(handle) = NULL ) then
		FB_UNLOCK()
		return @__fb_ctx.null_desc
	end if

    dst = fb_hStrAllocTemp( NULL, bytes )
    if ( dst <> NULL ) then
        dim as ssize_t read_count = 0
        if ( FB_HANDLE_IS_SCREEN(handle) <> NULL ) then
            dst->data[0] = 0
            while ( read_count <> bytes )
                res = fb_FileGetDataEx( handle, _
                                        0, _
                                        @dst->data[read_count], _
                                        bytes - read_count, _
										@_len, _
                                        TRUE, _
                                        FALSE )
                if( res <> FB_RTERROR_OK ) then
                    exit while
                end if
                read_count += _len

                /' add the null-term '/
                dst->data[read_count] = 0
            wend
        else
            res = fb_FileGetDataEx( handle, _
                                    0, _
                                    dst->data, _
									bytes, _
                                    @_len, _
                                    TRUE, _
                                    FALSE )
            if ( res=FB_RTERROR_OK ) then
                read_count += _len
            end if
        end if

        /' add the null-term '/
        dst->data[read_count] = 0

        if ( read_count <> bytes ) then
            fb_hStrSetLength( dst, read_count )
        end if
    else
        res = FB_RTERROR_OUTOFMEM
    end if

    if ( res <> FB_RTERROR_OK ) then
        if( dst <> NULL ) then
            fb_hStrDelTemp( dst )
		end if

        dst = @__fb_ctx.null_desc
    end if

    FB_UNLOCK()

    return dst
end function
end extern