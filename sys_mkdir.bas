/' mkdir function '/

#include "fb.bi"
#include "crt_extra/sys/stat.bi"

/':::::'/
extern "C"
function fb_MkDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

#ifdef HOST_WIN32
	res = _mkdir( path->data )
#else
	res = _mkdir( path->data, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH )
#endif

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern