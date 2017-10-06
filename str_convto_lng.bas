/' str$ routines for longint, ulongint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_LongintToStr FBCALL ( num as longint ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, sizeof( longint ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
		sprintf( dst->data, "%lld", num )

		fb_hStrSetLength( dst, strlen( dst->data ) )
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

/':::::'/
function fb_ULongintToStr FBCALL ( num as ulongint ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, sizeof( longint ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
		sprintf( dst->data, "%llu", num )

		fb_hStrSetLength( dst, strlen( dst->data ) )
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function
end extern