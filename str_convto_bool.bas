/' str$ routines for boolean
 *
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_hBoolToStr FBCALL ( num as ubyte ) as ubyte ptr
	static false_string as zstring ptr = @"false"
	static true_string as zstring ptr = @"true"

	return iif( num, true_string, false_string )
end function

/':::::'/
function fb_BoolToStr FBCALL ( num as ubyte, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ubyte ptr src = fb_hBoolToStr( num )
	dim as size_t src_len = strlen(src)

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, src_len ) <> NULL ) then
		fb_hStrCopy( dst.data, src, src_len )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern
