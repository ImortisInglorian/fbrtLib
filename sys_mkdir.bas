/' mkdir function '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_MkDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

	res = _mkdir( path->data )

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern