/' date$ function '/

#include "fb.bi"
#include "destruct_string.bi"
#include "crt/time.bi"

extern "C"
/':::::'/
function fb_Date FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as time_t rawtime
	dim as tm ptr ptm

	DBG_ASSERT( result <> NULL )

	/' guard by global lock because time/localtime might not be thread-safe '/
	FB_LOCK()

	rawtime = time_( NULL )

	/' Note: localtime() can return NULL due to weird value from time() '/
	ptm = localtime( @rawtime )
	if( ptm <> NULL ) then
		/' done last so it's not leaked '/
		if( fb_hStrAlloc( @dst, 2+1+2+1+4 ) <> NULL ) then
			sprintf( dst.data, "%02d-%02d-%04d", 1+ptm->tm_mon, ptm->tm_mday, 1900+ptm->tm_year )
		end if
	end if

	FB_UNLOCK()

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern