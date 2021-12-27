/' string$ function '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_StrFill1 FBCALL ( cnt as ssize_t, fchar as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( cnt > 0 ) then
		if ( fb_hStrAlloc( @dst, cnt ) <> NULL ) then
			/' fill it '/
			memset( dst.data, fchar, cnt )
			/' null char '/
			dst.data[cnt] = 0
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function

function fb_StrFill2 FBCALL ( cnt as ssize_t, src as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as long fchar

	if ( (cnt > 0) and (src <> NULL) andalso (src->data <> NULL) andalso (FB_STRSIZE( src ) > 0) ) then
		fchar = src->data[0]
		fb_StrFill1( cnt, fchar, result )
	end if

	return result
end function
end extern