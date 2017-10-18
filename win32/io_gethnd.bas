/' console handle getter '/

#include "../fb.bi"
#include "fb_private_console.bi"

dim shared as long is_init = FALSE

extern "C"
function fb_hConsoleGetHandle( is_input as long ) as HANDLE
	if ( is_init = FALSE ) then
		is_init = TRUE

		__fb_con.inHandle = GetStdHandle( STD_INPUT_HANDLE )
		__fb_con.outHandle = GetStdHandle( STD_OUTPUT_HANDLE )

    	if ( __fb_con.inHandle <> NULL ) then
    	    /' Initialize console mode to enable processed input '/
        	dim as DWORD dwMode
        	if ( GetConsoleMode( __fb_con.inHandle, @dwMode ) ) then
            	dwMode or= ENABLE_PROCESSED_INPUT
            	SetConsoleMode( __fb_con.inHandle, dwMode )
        	end if
    	end if

    	__fb_con.active = __fb_con.visible = 0
    	__fb_con.pgHandleTb(0) = __fb_con.outHandle
    end if

	return iif(is_input, __fb_con.inHandle, __fb_con.pgHandleTb(__fb_con.active))
end function

sub fb_hConsoleResetHandles()
	/' 
		Called by fb_FileResetEx() to cause fb_hConsoleGetHandle() 
		to reset the stored I/O handles 
	'/
	is_init = FALSE
end sub
end extern