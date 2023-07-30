/' time$ function '/

#include "fb.bi"
#include "crt/time.bi"

extern "C"
/':::::'/
function fb_Time FBCALL ( ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as time_t rawtime
	dim as tm ptr ptm

	/' guard by global lock because time/localtime might not be thread-safe '/
	FB_LOCK()

	rawtime = time_( NULL )

	/' Note: localtime() may return NULL, as documented on MSDN and Linux man pages,
	   and it has been observed to do that on at least one FB user's Windows system,
	   because of a negative time_t value from time(). '/
	ptm = localtime( @rawtime )
	if( ptm <> NULL ) then
		/' done last so it's not leaked '/
		dst = fb_hStrAllocTemp( NULL, 2+1+2+1+2 )
		if( dst <> NULL ) then
			sprintf( dst->data, "%02d:%02d:%02d", ptm->tm_hour, ptm->tm_min, ptm->tm_sec )
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