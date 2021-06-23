/' ERASE for static arrays: clear the elements '/
/' (for FBSTRING arrays, fb_ArrayStrErase() should be used instead) '/

#include "fb.bi"

extern "C"
function fb_ArrayClear FBCALL ( array as FBARRAY ptr ) as long
	if ( array->_ptr ) then
		memset( array->_ptr, 0, array->size )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern