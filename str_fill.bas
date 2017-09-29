/' string$ function '/

#include "fb.bi"

function fb_StrFill1 FBCALL ( cnt as ssize_t, fchar as integer ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	if ( cnt > 0 ) then
		/' alloc temp string '/
        dst = fb_hStrAllocTemp( NULL, cnt )
		if ( dst <> NULL ) then
			/' fill it '/
			memset( dst->_data, fchar, cnt )
			/' null char '/
			dst->_data[cnt] = 0
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
	dim as integer fchar

	if ( (cnt > 0) and (src <> NULL) and (src->_data <> NULL) and (FB_STRSIZE( src ) > 0) ) then
		fchar = src->_data[0]
		dst = fb_StrFill1( cnt, fchar )
	else
		dst = @__fb_ctx.null_desc
	end if
	/' del if temp '/
	fb_hStrDelTemp( src )

	return dst
end function
