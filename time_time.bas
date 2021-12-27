/' time$ function '/

#include "fb.bi"
#include "destruct_string.bi"
#include "crt/time.bi"

extern "C"
/':::::'/
function fb_Time FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as time_t rawtime
	dim as tm ptr ptm

	DBG_ASSERT( result <> NULL )

	/' guard by global lock because time/localtime might not be thread-safe '/
	FB_LOCK()

	rawtime = time_( NULL )

	/' Note: localtime() may return NULL, as documented on MSDN and Linux man pages,
	   and it has been observed to do that on at least one FB user's Windows system,
	   because of a negative time_t value from time(). '/
	ptm = localtime( @rawtime )
	if( ptm <> NULL ) then
		/' done last so it's not leaked '/
		if( fb_hStrAlloc( @dst, 2+1+2+1+2 ) <> NULL ) then
			sprintf( dst.data, "%02d:%02d:%02d", ptm->tm_hour, ptm->tm_min, ptm->tm_sec )
		end if
	end if

	FB_UNLOCK()

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern