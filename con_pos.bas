/' implementation of pos(dummy), simply redirects to fb_GetX() '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_Pos FBCALL ( dummy as long ) as long
	return fb_GetX()
end function
end extern