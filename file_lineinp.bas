/' line input function '/

#include "fb.bi"

#define BUFFER_LEN 1024

enum eInputMode
    eIM_Invalid
    eIM_ReadLine
    eIM_Read
end enum

private function fb_hFileLineInputEx( handle as FB_FILE ptr, dst as any ptr, dst_len as ssize_t, fillrem as long ) as long
    dim as ssize_t _len, readlen
    dim as ubyte buffer(0 to BUFFER_LEN - 1)
    dim as eInputMode  mode = eIM_Invalid

    if ( FB_HANDLE_USED(handle) = 0 ) then
        return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end if

    FB_LOCK()

    if ( handle->hooks->pfnReadLine <> NULL ) then
        mode = eIM_ReadLine
    elseif ( handle->hooks->pfnRead <> NULL and handle->hooks->pfnEof <> NULL ) then
        mode = eIM_Read
    end if

    select case ( mode )
        case eIM_Read:
            /' This is the VFS-compatible way to read a line ... but it's slow '/
            _len = 0
            readlen = 0
            while (handle->hooks->pfnEof(handle) = NULL)
                dim as long do_add = FALSE, do_break = FALSE
                dim as size_t read_len
                dim as long res = fb_FileGetDataEx( handle, 0, @buffer(0) + _len, 1, @read_len, FALSE, FALSE )
                if ( res = FB_RTERROR_OK and read_len = 1) then
                    dim as ubyte ch = buffer(_len)
                    if ( ch = asc("!\r") ) then
                        res = fb_FileGetDataEx( handle, 0, @ch, 1, @read_len, FALSE, FALSE )
                        if ( res = FB_RTERROR_OK and ch <> asc(!"\n") and read_len = 1) then
                            fb_FilePutBackEx( handle, @ch, 1 )
                        end if
                        ch = asc(!"\n")
                    end if
                    if ( ch = asc(!"\n") ) then
                        do_break = TRUE
                        do_add = TRUE
                    else
                        do_add = (_len = (ARRAY_SIZEOF(buffer)-1))
                    end if
                else
                    do_add = (_len <> 0)
                end if
                if ( do_add <> 0 or  handle->hooks->pfnEof( handle ) ) then
                    /' create temporary string to ensure that NUL's are preserved ...
                     * this function wants the length WITH the NUL character!!! '/
                    buffer(_len) = 0
                    dim as FBSTRING src
                    fb_StrAllocDescF( @buffer(0), _len + 1, @src )
                    if ( readlen = 0 ) then
                        fb_StrAssign( dst, dst_len, @src, -1, fillrem )
                    else
                        fb_StrConcatAssign ( dst, dst_len, @src, -1, fillrem )
                    end if
                    readlen += _len
                    _len = 0
                else
                    _len += 1
                end if
                if ( res <> FB_RTERROR_OK or do_break <> NULL ) then
                    exit while
                end if
            wend
            if ( readlen = 0 ) then
                /' del destine string '/
                if ( dst_len = -1 ) then
                    fb_StrDelete( cast(FBSTRING ptr, dst) )
                else
                    *cast(ubyte ptr, dst) = 0
                end if
            end if
        case eIM_ReadLine:
            /' The read line mode is the most comfortable ... but IMHO it's
             * only useful for special devices (like SCRN:) '/
            scope
                /' destine is a var-len string? read directly '/
                if ( dst_len = -1 ) then
                    handle->hooks->pfnReadLine( handle, dst )
                /' fixed-len or unknown size (ie: pointers)? use a temp var-len '/
                else
                    dim as FBSTRING str_result = ( 0, 0, 0 )

                    /' read complete line (may include NULs) '/
                    handle->hooks->pfnReadLine( handle, @str_result )

                    /' add contents of tempporary string to result buffer '/
                    fb_StrAssign( dst, dst_len, cast(any ptr, @str_result), -1, fillrem )

                    /' delete result '/
                    fb_StrDelete( @str_result )
                end if

            end scope
        case eIM_Invalid:
            FB_UNLOCK()
            return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    FB_UNLOCK()

    return fb_ErrorSetNum( FB_RTERROR_OK )
end function

extern "C"
function fb_FileLineInput FBCALL ( fnum as long, dst as any ptr, dst_len as ssize_t, fillrem as long ) as long
    return fb_hFileLineInputEx( FB_FILE_TO_HANDLE(fnum), dst, dst_len, fillrem )
end function
end extern