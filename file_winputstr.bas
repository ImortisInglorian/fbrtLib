/' winput$ function '/

#include "fb.bi"

extern "C"
function fb_FileWstrInput FBCALL ( chars as ssize_t, fnum as long ) as FB_WCHAR ptr
    dim as FB_FILE ptr handle
	dim as FB_WCHAR ptr dst
    dim as size_t _len
    dim as long res = FB_RTERROR_OK

	fb_DevScrnInit_ReadWstr( )

	FB_LOCK()

    handle = FB_FILE_TO_HANDLE(fnum)

    if ( FB_HANDLE_USED(handle) <> NULL ) then
		FB_UNLOCK()
		return NULL
	end if

    dst = fb_wstr_AllocTemp( chars )
    if ( dst <> NULL ) then
        dim as ssize_t read_chars = 0
        if ( FB_HANDLE_IS_SCREEN(handle) <> NULL ) then
            while ( read_chars <> chars )
                res = fb_FileGetDataEx( handle, 0, cast(any ptr, @dst[read_chars]),chars - read_chars, @_len, TRUE, TRUE )
                if ( res <> FB_RTERROR_OK ) then
                    exit while
				end if

                read_chars += _len
            wend
        else
            res = fb_FileGetDataEx( handle, 0, cast(any ptr, dst), chars, @_len, TRUE, TRUE )
			read_chars = chars
        end if

		if ( res = FB_RTERROR_OK ) then
			dst[read_chars] = 0
		else
			fb_wstr_Del( dst )
			dst = NULL
		end if

    else
        res = FB_RTERROR_OUTOFMEM
	end if
	FB_UNLOCK()

    return dst
end function
end extern
