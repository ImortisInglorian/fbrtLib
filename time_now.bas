/' NOW function '/

#include "fb.bi"
#include "crt/time.bi"

extern "C"
/':::::'/
function fb_Now FBCALL ( ) as double
	dim as double dblTime, dblDate
	dim as time_t rawtime
	dim as tm ptr ptm

	/' guard by global lock because time/localtime might not be thread-safe '/
	FB_LOCK()

	time_( @rawtime )

	/' Note: localtime() can return NULL due to weird value from time() '/
	ptm = localtime( @rawtime )
	if (ptm = NULL) then
		return 0.0
	end if

	dblDate = fb_DateSerial( 1900 + ptm->tm_year, 1 + ptm->tm_mon, ptm->tm_mday )
	dblTime = fb_TimeSerial( ptm->tm_hour, ptm->tm_min, ptm->tm_sec )

	FB_UNLOCK()

	return dblDate + dblTime
end function
end extern