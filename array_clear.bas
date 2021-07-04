/' ERASE for static arrays: clear the elements 

   fb_ArrayClear() is called directly if it is known at
   compile time that the array is static (fixed length)

   fb_ArrayClear() is called indirectly through fb_ArrayClearObj()
   after the array elements have been destructed

   fb_ArrayDestructStr() clears the array so there is
   no need to call fb_ArrayClear() also

   for plain arrays: fbc calls fb_ArrayClear()
   for object arrays: fbc calls fb_ArrayClearObj()
   for FBSTRING arrays: fbc calls fb_ArrayDestructStr()
'/

#include "fb.bi"

extern "C"
function fb_ArrayClear FBCALL ( array as FBARRAY ptr ) as long
	if ( array->_ptr ) then
		memset( array->_ptr, 0, array->size )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern
