/' write [#] functions '/

#include "fb.bi"
extern "C"
/':::::'/
sub fb_WriteSingle FBCALL ( fnum as long, _val as single, mask as long )
	dim as ubyte buffer(0 to 8+1+8+1+1)

	fb_hFloat2Str( cast(double, _val), @buffer(0), 7, 0 )

	if ( mask and FB_PRINT_BIN_NEWLINE ) then
    	strcat( @buffer(0), FB_BINARY_NEWLINE )
	elseif ( mask and FB_PRINT_NEWLINE ) then
    	strcat( @buffer(0), FB_NEWLINE )
	else
    	strcat( @buffer(0), "," )
	end if

	fb_hFilePrintBufferEx( FB_FILE_TO_HANDLE( fnum ), @buffer(0), strlen( @buffer(0) ) )

end sub

/':::::'/
sub fb_WriteDouble FBCALL ( fnum as long, _val as double, mask as long )
	dim as ubyte buffer(0 to 16+1+8)

	fb_hFloat2Str( _val, @buffer(0), 16, 0 )

	if ( mask and FB_PRINT_BIN_NEWLINE ) then
    	strcat( @buffer(0), FB_BINARY_NEWLINE )
	elseif ( mask and FB_PRINT_NEWLINE ) then
    	strcat( @buffer(0), FB_NEWLINE )
	else
    	strcat( @buffer(0), "," )
	end if

	fb_hFilePrintBufferEx( FB_FILE_TO_HANDLE( fnum ), @buffer(0), strlen( @buffer(0) ) )
end sub
end extern