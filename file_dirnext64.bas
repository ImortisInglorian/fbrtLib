#include "fb.bi"

extern "C"
function fb_DirNext64 FBCALL ( outattrib as longint ptr ) as FBSTRING ptr
	dim as long ioutattrib
	dim as FBSTRING ptr res

	res = fb_DirNext( @ioutattrib )

	*outattrib = ioutattrib
	return res
end function
end extern