/' get the executable's name '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	GetModuleFileName( GetModuleHandle( NULL ), dst, maxlen )

	dim as ubyte ptr p = strrchr( dst, cast(long, sadd("\\")) )
	if ( p <> NULL ) then
		p += 1
	else
		p = dst
	end if
	return p
end function
end extern