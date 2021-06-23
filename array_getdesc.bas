/' fbc-int API: array descriptor internals '/

#include "fb.bi"

extern "c"
function fb_ArrayGetDesc FBCALL ( array as FBARRAY ptr ) as FBARRAY ptr
	return array
end function
end extern
