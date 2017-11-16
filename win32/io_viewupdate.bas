/' view print update (console, no gfx) '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
sub fb_ConsoleViewUpdate( )
	fb_hUpdateConsoleWindow( )
end sub
end extern