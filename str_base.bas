#include "fb.bi"

extern "C"
/':::::'/
function fb_HEX FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEX_i ( num, result )
end function


/':::::'/
function fb_OCT FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_OCT_i ( num, result )
end function


/':::::'/
function fb_BIN FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BIN_i ( num, result )
end function
end extern