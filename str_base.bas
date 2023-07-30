#include "fb.bi"

extern "C"
/':::::'/
function fb_HEX FBCALL ( num as long ) as FBSTRING ptr
	return fb_HEX_i ( num )
end function


/':::::'/
function fb_OCT FBCALL ( num as long ) as FBSTRING ptr
	return fb_OCT_i ( num )
end function


/':::::'/
function fb_BIN FBCALL ( num as long ) as FBSTRING ptr
	return fb_BIN_i ( num )
end function
end extern