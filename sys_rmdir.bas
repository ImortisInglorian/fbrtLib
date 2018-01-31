/' rmdir function '/

#include "fb.bi"
#include "crt/io.bi"

extern "C"
/':::::'/
function  fb_RmDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

	res = _rmdir( path->data )

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern