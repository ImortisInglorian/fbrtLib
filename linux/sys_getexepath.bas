/' get the executable path '/

#include "../fb.bi"
#include "crt/sys/stat.bi"

Extern "c"
Function fb_hGetExePath( dst as ubyte ptr, maxlen as ssize_t ) As ubyte ptr

	dim p as ubyte ptr
	dim finfo as stat
	dim len as ssize_t

	if (stat("/proc/self/exe", @finfo) = 0) then
		len = readlink("/proc/self/exe", dst, maxlen - 1)
		if(len > -1) then
			/' Linux-like proc fs is available '/
			dst[len] = 0
			p = strrchr(dst, asc("/"))
			if (p = dst) then /' keep the "/" rather than returning "" '/
				*(p + 1) = 0
			elseif (p <> Null) then
				*p = 0
			else
				dst[0] = 0
			end if
		end if
	else
		p = NULL
	end if

	return p
End Function
End Extern