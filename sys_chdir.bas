/' chdir function '/

#include "fb.bi"
''#include "crt/unistd.bi"


extern "C"
function fb_ChDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

	res = _chdir( path->data )

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern