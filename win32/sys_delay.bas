#include "../fb.bi"
#include "windows.bi"

extern "C"
sub fb_Delay FBCALL ( msecs as long )
	Sleep_( msecs )
end sub
end extern