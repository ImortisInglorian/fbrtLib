/' write [#] functions '/

#include "fb.bi"

extern "C"
private sub hWriteStrEx( handle as FB_FILE ptr, s as ubyte const ptr, _len as size_t, mask as long )
    dim as ubyte ptr buff
	dim as ssize_t bufflen

    /' close quote + new-line or comma '/
    if ( mask and FB_PRINT_BIN_NEWLINE ) then
		buff = @(!"\"" FB_BINARY_NEWLINE)
		bufflen = strlen( @(!"\"" FB_BINARY_NEWLINE) )
    elseif ( mask and FB_PRINT_NEWLINE ) then
		buff = @(!"\"" FB_NEWLINE)
		bufflen = strlen( @(!"\"" FB_NEWLINE) )
    else
		buff = @(!"\",")
		bufflen = 2
	end if

    FB_LOCK( )

    /' open quote '/
    fb_hFilePrintBufferEx( handle, @(!"\""), 1 )

    if ( _len <> 0 ) then
        FB_PRINT_EX( handle, s, _len, 0 )
	end if

    fb_hFilePrintBufferEx( handle, buff, bufflen )

    FB_UNLOCK( )
end sub

sub fb_WriteString FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
	dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE( fnum )

	if ( (s <> NULL) and (s->data <> NULL) ) then
		hWriteStrEx( handle, s->data, FB_STRSIZE(s), mask )
	else
		if ( mask and FB_PRINT_BIN_NEWLINE ) then
			fb_hFilePrintBufferEx( handle, @(!"\"\"" FB_BINARY_NEWLINE), 1+1+sizeof(FB_BINARY_NEWLINE)-1 )
		elseif ( mask and FB_PRINT_NEWLINE ) then
			fb_hFilePrintBufferEx( handle, @(!"\"\"" FB_NEWLINE), 1+1+sizeof(FB_NEWLINE)-1 )
		else
			fb_hFilePrintBufferEx( handle, @(!"\"\","), 1+1+1 )
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( s )
end sub

sub fb_WriteFixString FBCALL ( fnum as long, s as ubyte ptr, mask as long )
	dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE( fnum )

	if ( s <> NULL ) then
		hWriteStrEx( handle, s, strlen( s ), mask )
	else
		if( mask and FB_PRINT_BIN_NEWLINE ) then
			fb_hFilePrintBufferEx( handle, @(!"\"\"" FB_BINARY_NEWLINE), 1+1+sizeof(FB_BINARY_NEWLINE)-1 )
		elseif ( mask and FB_PRINT_NEWLINE ) then
			fb_hFilePrintBufferEx( handle, @(!"\"\"" FB_NEWLINE), 1+1+sizeof(FB_NEWLINE)-1 )
		else
			fb_hFilePrintBufferEx( handle, @(!"\"\","), 1+1+1 )
		end if
	end if
end sub
end extern