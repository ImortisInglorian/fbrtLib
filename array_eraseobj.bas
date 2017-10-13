/' ERASE for dynamic arrays of objects: destruct elements and free the array '/

#include "fb.bi"

extern "C"
function fb_ArrayEraseObj FBCALL ( array as FBARRAY ptr, dtor as FB_DEFCTOR ) as long
	fb_ArrayDestructObj( array, dtor )
	fb_ArrayErase( array, 0 )
	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern