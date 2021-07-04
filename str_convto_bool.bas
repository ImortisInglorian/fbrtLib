/' str$ routines for boolean
 *
 '/

#include "fb.bi"

extern "C"

/':::::'/
function fb_hBoolToStr FBCALL ( num as ubyte ) as ubyte ptr
	static false_string as zstring ptr = @"false"
	static true_string as zstring ptr = @"true"

	return iif( num, true_string, false_string )
end function

/':::::'/
function fb_BoolToStr FBCALL ( num as ubyte ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	dst = fb_hStrAllocTemp( NULL, 8 )
	if ( dst <> NULL ) then
		dim as ubyte ptr src = fb_hBoolToStr( num )
		fb_hStrCopy( dst->data, src, strlen(src) )
		fb_hStrSetLength( dst, strlen(src) )
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function
end extern
