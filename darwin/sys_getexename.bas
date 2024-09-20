/' get the executable's name '/

#include "../fb.bi"

extern "C"
declare function _NSGetExecutablePath(buf as ubyte ptr, bufsize as uint32_t ptr) as long

function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	dim as ubyte ptr p
	dim as uint32_t _len = maxlen
   
	if (_NSGetExecutablePath(dst, @_len) = 0) then
		dst[_len] = 0
		p = strrchr(dst, asc("/"))
		if (p <> NULL) then
			p += 1
		else
			p = dst
		end if
	else
		p = NULL
	end if

	return p
end function
end extern