/' redim preserve function '/

#include "fb.bi"

extern "C"
function fb_ArrayRedimPresvObj ( array as FBARRAY ptr, element_len as size_t, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR, dimensions as size_t, ... ) as long
	dim as cva_list ap
	dim as long res

	cva_start( ap, dimensions )

	/' Have to assume doclear=TRUE, because we have no doclear parameter here,
	and don't know what to do, so better be safe. '/

	/' new? '/
	if ( array->_ptr = NULL ) then
		res = fb_hArrayAlloc( array, element_len, TRUE, ctor, dimensions, ap )
	else
		/' realloc.. '/
		dim as FB_DTORMULT dtor_mult = iif(dtor <> NULL, @fb_hArrayDtorObj, NULL )
		res = fb_hArrayRealloc( array, element_len, TRUE, ctor, dtor_mult, dtor, dimensions, ap )
	end if

	cva_end( ap )

	return res
end function
end extern
