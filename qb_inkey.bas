/' QB compatible INKEY '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_InkeyQB FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
	DBG_ASSERT( result <> NULL )
	dim as FBSTRING ptr res = fb_Inkey( result )
	
	FB_LOCK()
	
	if ( res <> NULL andalso res->data <> NULL andalso ( FB_STRSIZE(res) = 2 ) andalso ( res->data[0] = FB_EXT_CHAR ) ) then
		res->data[0] = 0
	end if

	FB_UNLOCK()
	
	return res
end function
end extern