/' ERASE for dynamic arrays of var-len strings '/

#include "fb.bi"

extern "C"
sub fb_ArrayStrErase FBCALL ( array as FBARRAY ptr )
	fb_ArrayErase( array, -1 )
end sub
end extern