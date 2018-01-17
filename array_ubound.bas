/' ubound function '/

#include "fb.bi"

/' Returns the ubound of the given dimension, or -1 if the given dimension
   doesn't exist.

   Special case: ubound( a, 0 ) returns the dimension count.

   Note: The dimension count can be set (in the descriptor) even for unallocated
   arrays, as it's fixed and determines the descriptor size. However, currently
   ubound( a, 0 ) will always return 0 for unallocated arrays. '/
extern "C"
function fb_ArrayUBound FBCALL ( array as FBARRAY ptr, dimension as ssize_t ) as ssize_t
	/' given dimension is 1-based '/
	dimension -= 1

	/' Querying dimension count? '/
	if ( dimension = -1 ) then
		if ( array->data <> 0 ) then
			return cast(ssize_t, array->dimensions)
		end if
		return 0
	end if

	/' Querying dimension's ubound. '/

	/' unallocated array or out-of-bound dimension? '/
	if ( (array->data = NULL) or (dimension < 0) or (cast(size_t, dimension) >= array->dimensions) ) then
		return -1
	end if
	return array->dimTB(dimension).ubound
end function
end extern