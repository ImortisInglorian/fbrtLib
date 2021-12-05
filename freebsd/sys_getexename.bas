/' get the executable's name '/

#include "../fb.bi"
#include "sys/sysctl.bi"

Extern "c"
Function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

	dim len_ as size_t = maxlen
	dim p as ubyte ptr
	dim mib(0 to 3) as long = {CTL_KERN, KERN_PROC, KERN_PROC_PATHNAME, -1}
	
	if (sysctl(@mib(0), 4, dst, @len_, NULL, 0) = 0) then
		dst[len_] = 0
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
End Function
End Extern
