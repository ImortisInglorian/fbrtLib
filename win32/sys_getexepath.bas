/' get the executable path '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hGetExePath( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	GetModuleFileName( GetModuleHandle( NULL ), dst, maxlen )

	dim as ubyte ptr p = strrchr( dst, asc(!"\\") )
	if ( p <> NULL ) then
		*p = 0
	else
		dst[0] = 0
	end if

	/' just a drive letter? make sure \ follows to prevent using relative path '/
	if ( maxlen > 3 and dst[2] = 0 and dst[1] = asc(":") ) then
		if ( (dst[0] and not(32)) >= asc("A") and (dst[0] and not(32)) <= asc("Z") ) then
			dst[2] = asc(!"\\")
			dst[3] = 0
		end if
	end if

	return p
end function
end extern