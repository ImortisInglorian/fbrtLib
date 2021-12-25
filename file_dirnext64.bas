#include "fb.bi"

extern "C"
function fb_DirNext64 FBCALL ( outattrib as longint ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as long ioutattrib
	DBG_ASSERT( result <> NULL )
	dim as FBSTRING ptr res = fb_DirNext( @ioutattrib, result )

	*outattrib = ioutattrib
	return res
end function
end extern