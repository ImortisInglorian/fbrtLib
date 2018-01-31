/' write [#] functions '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteVoid FBCALL ( fnum as long, mask as long )
    dim as ubyte ptr buffer

    if ( mask and FB_PRINT_NEWLINE ) then
    	*buffer = asc(FB_NEWLINE)

    elseif ( mask and FB_PRINT_PAD ) then
    	*buffer = asc(!"\t")

    else
    	buffer = NULL
	end if

    if ( buffer <> NULL ) then
        FB_PRINT(fnum, buffer, mask)
	end if
end sub
end extern