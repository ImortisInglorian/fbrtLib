/' string$ function '/

#include "fb.bi"

extern "C"
function fb_StrFill1 FBCALL ( cnt as ssize_t, fchar as long ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	if ( cnt > 0 ) then
		/' alloc temp string '/
        dst = fb_hStrAllocTemp( NULL, cnt )
		if ( dst <> NULL ) then
			/' fill it '/
			memset( dst->data, fchar, cnt )
			/' null char '/
			dst->data[cnt] = asc( !"\000" ) '' NUL CHAR
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

function fb_StrFill2 FBCALL ( cnt as ssize_t, src as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as long fchar

	if ( (cnt > 0) and (src <> NULL) andalso (src->data <> NULL) andalso (FB_STRSIZE( src ) > 0) ) then
		fchar = src->data[0]
		dst = fb_StrFill1( cnt, fchar )
	else
		dst = @__fb_ctx.null_desc
	end if
	/' del if temp '/
	fb_hStrDelTemp( src )

	return dst
end function
end extern