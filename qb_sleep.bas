/' QB compatible SLEEP '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_SleepQB FBCALL ( secs as long )
	fb_Sleep( iif(secs < 0, secs, secs * 1000) )
end sub
end extern