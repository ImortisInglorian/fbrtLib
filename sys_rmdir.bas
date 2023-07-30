/' rmdir function '/

#include "fb.bi"
#include "crt/io.bi"

extern "C"
/':::::'/
function  fb_RmDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

#ifdef HOST_WIN32
	res = _rmdir( path->data )
#else
	res = rmdir_( path->data )
#endif

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern