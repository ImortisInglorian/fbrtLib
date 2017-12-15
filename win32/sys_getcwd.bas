/' get current dir '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hGetCurrentDir( dst as ubyte ptr, maxlen as ssize_t ) as ssize_t
	return GetCurrentDirectory( maxlen, dst )
end function
end extern