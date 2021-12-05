/' get the executable's name '/

#include "../fb.bi"
#include "crt/sys/stat.bi"

Extern "c"
Function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

	dim p as ubyte ptr
	dim linkname(0 to 1023) as ubyte
	dim linknameptr as ubyte ptr = @linkname(0)
	dim finfo as stat
	dim len_ as ssize_t

	sprintf(linknameptr, "/proc/%d/exe", getpid())
	if (stat(linknameptr, @finfo) = 0) then
		len_ = readlink(linknameptr, dst, maxlen - 1)
		if (len_ > -1) then
			/' Linux-like proc fs is available '/
			dst[len_] = 0
			p = strrchr(dst, asc("/"))
			if (p <> NULL) then
				p += 1
			else
				p = dst
			end if
		end if
	else
		p = NULL
	end if

	return p
End Function
End Extern
