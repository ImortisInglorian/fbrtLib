#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hGetShortPath( src as ubyte ptr, dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	if ( strchr( src, 32 ) = NULL ) then
		strcpy( dst, src )
	else
	 	GetShortPathName( src, dst, maxlen )
	end if

	return dst
end function
end extern