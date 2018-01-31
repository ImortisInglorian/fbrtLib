/' write [#] function (boolean) '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_WriteBool FBCALL ( fnum as long, _val as ubyte, mask as long )
	FB_WRITENUM( fnum, fb_hBoolToStr( _val ), mask, "%s" )
end sub
end extern