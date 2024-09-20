/' get the executable path '/

#include "../fb.bi"
''#include "mach-o/dyld.h"

extern "C"

declare function _NSGetExecutablePath(buf as ubyte ptr, bufsize as uint32_t ptr) as long

function fb_hGetExePath( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	dim as ubyte ptr p
	dim as uint32_t _len = maxlen

	if (_NSGetExecutablePath(dst, @_len) = 0) then
		dst[len] = 0
		p = strrchr(dst, asc("/"))
		if (p = dst) then /' keep the "/" rather than returning "" '/
			p += 1
			*p = 0
		elseif (p <> 0) then
			*p = 0
			/' OS X likes to append "/." to the path, so remove it '/
			p -= 2
			if (*p = asc("/") and *(p-1) = asc(".")) then
				*p = 0
			end if
		else
			dst[0] = 0
	else
		p = NULL
	end if
	return p
end function
end extern