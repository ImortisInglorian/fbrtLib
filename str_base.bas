#include "fb.bi"

/':::::'/
function fb_HEX FBCALL ( num as integer ) as FBSTRING ptr
	return fb_HEX_i ( num )
end function


/':::::'/
function fb_OCT FBCALL ( num as integer ) as FBSTRING ptr
	return fb_OCT_i ( num )
end function


/':::::'/
function fb_BIN FBCALL ( num as Integer ) as FBSTRING ptr
	return fb_BIN_i ( num )
end function
