/' ERASE for dynamic arrays of objects: destruct elements and free the array '/

#include "fb.bi"

extern "C"
function fb_ArrayEraseObj FBCALL ( array as FBARRAY ptr, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long

	if( (array->flags and FBARRAY_FLAGS_FIXED_LEN) <> 0 ) then
		fb_ArrayClearObj( array, ctor, dtor )
	else
		if( dtor ) then
			fb_ArrayDestructObj( array, dtor )
		end if
		fb_ArrayErase( array )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )

end function
end extern
