#include "fb.bi"

extern "C"
function fb_Dir64 FBCALL ( filespec as FBSTRING ptr, attrib as long, outattrib as longint ptr, res as FBSTRING ptr ) as FBSTRING ptr
	dim as long ioutattrib
	DBG_ASSERT(res <> NULL)

	fb_Dir( filespec, attrib, @ioutattrib, res )

	*outattrib = ioutattrib
	return res
end function
end extern