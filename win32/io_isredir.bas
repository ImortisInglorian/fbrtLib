#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleIsRedirected ( is_input as long ) as long
	dim as DWORD mode
	
	return iif((GetConsoleMode( iif(is_input, __fb_in_handle, __fb_out_handle), @mode ) = 0), FB_TRUE, FB_FALSE)
end function
end extern