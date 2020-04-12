/' fbc-int API: array descriptor internals '/

#include "fb.bi"

extern "c"
function fb_ArrayGetDesc( array as FBARRAY ptr ) as FBARRAY ptr
	return array
end function
end extern
