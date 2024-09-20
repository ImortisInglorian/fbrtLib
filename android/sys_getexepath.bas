/' get the executable path '/

#include "../fb.bi"
#include "crt/sys/stat.bi"

extern "C"
function fb_hGetExePath( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
	dim as ubyte ptr char
	dim as stat finfo
	dim as ssize_t _len

	if (stat("/proc/self/exe", @finfo) == 0) and (_len = readlink("/proc/self/exe", dst, maxlen - 1)) > -1 then
		/' Linux-like proc fs is available. But if running from an app this uselessly points at /system/bin. '/
		dst[_len] = "\0"
		p = strrchr(dst, "/")
		if p = dst then /' keep the "/" rather than returning "" '/
			*(p + 1) = "\0"
		else if (p) then
			*p = "\0"
		else
			dst[0] = "\0"
      end if
	else
		p = NULL
	end if

	return p
end function
end extern