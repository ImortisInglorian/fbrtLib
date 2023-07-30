#include "fb.bi"

extern "C"
function fb_Dir64 FBCALL ( filespec as FBSTRING ptr, attrib as long, outattrib as longint ptr ) as FBSTRING ptr
	dim as long ioutattrib
	dim as FBSTRING ptr res

	res = fb_Dir( filespec, attrib, @ioutattrib )

	*outattrib = ioutattrib
	return res
end function
end extern