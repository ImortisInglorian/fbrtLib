/' lbound function '/

#include "fb.bi"

/' Returns the lbound of the given dimension, or 0 if the given dimension
   doesn't exist. Together with ubound() returning -1 in such cases, we'll have
   the lbound > ubound situation to detect unallocated arrays.

   Using lbound == 0 for unallocated arrays is also good because it allows FB
   code such as
      @array(lbound(array)) <> NULL
   to keep working.

   Special case: lbound( a, 0 ) always returns 1 (the lbound of the dimTB).
   Together with ubound() returning the dimension count or 0, we'll also have
   the lbound > ubound situation here for unallocated arrays.

   Note: The dimension count can be set (in the descriptor) even for unallocated
   arrays, as it's fixed and determines the descriptor size. '/

extern "C"
function fb_ArrayLBound FBCALL ( array as FBARRAY ptr, dimension as ssize_t ) as ssize_t
	/' given dimension is 1-based '/
	dimension -= 1

	/' Querying dimTB's lbound? '/
	if ( dimension = -1 ) then
		return 1
	end if

	/' Querying dimension's lbound. '/

	/' unallocated array or out-of-bound dimension? '/
	if ( (array->data = NULL) or (dimension < 0) or (cast(size_t, dimension) >= array->dimensions) ) then
		return 0
	end if
	return array->dimTB(dimension).lbound
end function
end extern