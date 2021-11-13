#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hGetShortPath( src as ubyte ptr, dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	if ( strchr( src, Asc(" ") ) = NULL ) then
		strncpy( dst, src, maxlen )
		dst[maxlen - 1] = 0
	else
	 	GetShortPathName( src, dst, maxlen )
	end if

	return dst
end function
end extern