#include "../fb.bi"
#include "windows.bi"

extern "C"
sub fb_Delay FBCALL ( msecs as long )
	Sleep( msecs )
end sub
end extern