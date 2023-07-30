/' chdir function '/

#include "fb.bi"
#ifndef HOST_WIN32
/'
!!! FIXME !!! - update the crt headers
''' The Windows unistd,bi tries including getopt.bi that doesn't exist
''' Luckily windows' _chdir is in io.bi so doesn't need this
'/
#include "crt/unistd.bi"
#endif


extern "C"
function fb_ChDir FBCALL ( path as FBSTRING ptr ) as long
	dim as long res

#ifdef HOST_WIN32
	res = _chdir( path->data )
#else
	res = chdir_( path->data )
#endif

	/' del if temp '/
	fb_hStrDelTemp( path )

	return res
end function
end extern