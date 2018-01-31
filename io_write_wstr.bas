/' write [#] wstring functions '/

#include "fb.bi"

extern "C"
sub fb_WriteWstr FBCALL ( fnum as long, s as FB_WCHAR ptr, mask as long )
    dim as FB_WCHAR ptr buff
	dim as ssize_t _len, bufflen
    dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE( fnum )

	if ( s = NULL ) then
		if ( mask and FB_PRINT_BIN_NEWLINE ) then
			fb_hFilePrintBufferWstrEx( handle, @_LC(!"\"\"" FB_BINARY_NEWLINE), 1+1+sizeof(FB_BINARY_NEWLINE)-1 )
		elseif ( mask and FB_PRINT_NEWLINE ) then
			fb_hFilePrintBufferWstrEx( handle, @_LC(!"\"\"" FB_NEWLINE), 1+1+sizeof(FB_NEWLINE)-1 )
		else
			fb_hFilePrintBufferWstrEx( handle, @_LC(!"\"\","), 1+1+1 )
		end if
		return
	end if

    /' close quote + new-line or comma '/
    if ( mask and FB_PRINT_BIN_NEWLINE ) then
		buff = @_LC(!"\"" FB_BINARY_NEWLINE)
		bufflen = fb_wstr_Len( @_LC(!"\"" FB_BINARY_NEWLINE) )
    elseif ( mask and FB_PRINT_NEWLINE ) then
		buff = @_LC(!"\"" FB_NEWLINE)
		bufflen = fb_wstr_Len( @_LC(!"\"" FB_NEWLINE) )
    else
		buff = @_LC(!"\",")
		bufflen = 2
	end if

    FB_LOCK( )

    /' open quote '/
    fb_hFilePrintBufferWstrEx( handle, @_LC(!"\""), 1 )

    _len = fb_wstr_Len( s )
    if ( _len <> 0 ) then
        FB_PRINTWSTR_EX( handle, s, _len, 0 )
	end if

    fb_hFilePrintBufferWstrEx( handle, buff, bufflen )

    FB_UNLOCK( )
end sub
end extern