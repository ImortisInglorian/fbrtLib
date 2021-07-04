/' QB compatible INKEY '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_InkeyQB FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr res = fb_Inkey()
	
	FB_LOCK()
	
	if ( res <> NULL andalso res->data <> NULL andalso ( FB_STRSIZE(res) = 2 ) andalso ( res->data[0] = FB_EXT_CHAR ) ) then
		res->data[0] = 0
	end if

	FB_UNLOCK()
	
	return res
end function
end extern