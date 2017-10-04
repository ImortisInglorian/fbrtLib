/' str$ routines for boolean
 *
 '/

#include "fb.bi"

static shared false_string as ubyte ptr = sadd("false")
static shared true_string as ubyte ptr = sadd("true")

extern "C"
/':::::'/
function fb_hBoolToStr FBCALL ( num as ubyte ) as ubyte ptr
	return iif(num, true_string, false_string)
end function

/':::::'/
function fb_BoolToStr FBCALL ( num as ubyte ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	dst = fb_hStrAllocTemp( NULL, 8 )
	if ( dst <> NULL ) then
		dim as ubyte ptr src = fb_hBoolToStr( num )
		fb_hStrCopy( dst->_data, src, strlen(src) )
		fb_hStrSetLength( dst, strlen(src) )
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function
end extern