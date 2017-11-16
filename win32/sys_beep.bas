/' beep function '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
sub fb_Beep FBCALL ( )
	_Beep( 1000, 250 )
end sub
end extern