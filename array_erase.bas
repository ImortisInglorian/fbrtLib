/' ERASE for dynamic arrays: free the array '/

#include "fb.bi"

extern "C"
function fb_ArrayErase FBCALL ( array as FBARRAY ptr, isvarlen as long ) as long /'isvarlen = legacy '/
	/' ptr can be NULL, for global dynamic arrays that were never allocated,
	   but will still be destroyed on program exit '/
	if ( array->_ptr <> NULL ) then
		if ( isvarlen <> NULL ) then
			fb_ArrayDestructStr( array )
		end if
		free( array->_ptr )
		fb_ArrayResetDesc( array )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern