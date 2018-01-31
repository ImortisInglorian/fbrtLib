/' RUN function '/

#include "fb.bi"

extern "C"
function fb_Run FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as long
	if ( fb_ExecEx( program, args, FALSE ) <> -1 ) then
		fb_End( 0 )
	end if

    return -1
end function
end extern