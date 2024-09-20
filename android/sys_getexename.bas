/' get the executable's name '/

#include "../fb.bi"
#include "crt/sys/stat.bi"

extern"C"
function fb_hGetExeName( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	dim as ubtye ptr p
	dim as ubyte linkname(0 to 10243)
	dim as stat finfo
	dim as ssize_t _len

	sprintf(linkname, "/proc/%d/exe", getpid())
	if stat(linkname, @finfo) = 0 and _len = readlink(linkname, dst, maxlen - 1) > -1 then
		/' Linux-like proc fs is available '/
		dst[_len] = "\0"
		p = strrchr(dst, "/")
		if (p <> NULL)
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