/' ERASE for dynamic arrays of var-len strings '/

#include "fb.bi"

extern "C"
sub fb_ArrayStrErase FBCALL ( array as FBARRAY ptr )

	fb_ArrayDestructStr( array )

	/' only free the memory if it's not a fixed length array '/
	if( array andalso not((array->flags and FBARRAY_FLAGS_FIXED_LEN) <> 0) ) then
		fb_ArrayErase( array )
	end if

end sub
end extern