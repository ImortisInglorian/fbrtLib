/' redim function '/

#include "fb.bi"

extern "C"
function fb_ArrayRedimObj ( array as FBARRAY ptr, element_len as size_t, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR,dimensions as size_t, ... ) as long
	dim as va_list ap
	dim as long res

	/' free old '/
	if ( dtor <> 0 ) then
		fb_ArrayDestructObj( array, dtor )
	end if
	fb_ArrayErase( array, 0 )

	'va_start( ap, dimensions )
	ap = va_first()
	/' Have to assume doclear=TRUE, because we have no doclear parameter here,
	   and don't know what to do, so better be safe. '/
	res = fb_hArrayAlloc( array, element_len, TRUE, ctor, dimensions, ap )
	'va_end( ap )

	return res
end function
end extern