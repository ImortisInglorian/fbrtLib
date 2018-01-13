/' locate function entry point, returns current position '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_Locate FBCALL ( row as long, col as long, cursor as long, start as long, _stop as long ) as long
    dim as long new_pos
	dim as long res = fb_LocateEx( row, col, cursor, @new_pos )
    if ( res <> FB_RTERROR_OK ) then
        fb_LocateEx( 0, 0, cursor, @new_pos )
	end if
	return new_pos
end function
end extern
