#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleGetMaxRow( ) as long
	dim as COORD _max_ = GetLargestConsoleWindowSize( __fb_out_handle )
	return iif((_max_.Y = 0), FB_SCRN_DEFAULT_HEIGHT, _max_.Y + 1)
end function
end extern