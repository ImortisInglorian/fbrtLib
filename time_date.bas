/' date$ function '/

#include "fb.bi"
#include "crt/time.bi"

extern "C"
/':::::'/
function fb_Date FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as time_t rawtime
	dim as tm ptr ptm

	/' guard by global lock because time/localtime might not be thread-safe '/
	FB_LOCK()

	rawtime = time_( NULL )

	/' Note: localtime() can return NULL due to weird value from time() '/
	ptm = localtime( @rawtime )
	if( ptm <> NULL ) then
		/' done last so it's not leaked '/
		dst = fb_hStrAllocTemp( NULL, 2+1+2+1+4 )
		if( dst <> NULL ) then
			sprintf( dst->data, "%02d-%02d-%04d", 1+ptm->tm_mon, ptm->tm_mday, 1900+ptm->tm_year )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	FB_UNLOCK()

	return dst
end function
end extern