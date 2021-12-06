/' get the executable path '/

#include "../fb.bi"
#include "crt/sys/stat.bi"

Extern "c"
Function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

	dim p as ubyte ptr
	dim finfo as stat
	dim len_ as ssize_t
	dim procpath as Const ZString Ptr = sadd("/proc/curproc/exe")
	
	if ((stat(procpath, @finfo) = 0) then
		len_ = readlink(procpath, dst, maxlen - 1)
		if(len_ > -1) then
			/' NetBSD-like proc fs is available '/
			dst[len_] = 0
			p = strrchr(dst, asc("/"))
			if (p = dst) then /' keep the "/" rather than returning "" '/
				*(p + 1) = 0
			elseif p <> Null then
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
