/' redim preserve function '/

#include "fb.bi"

extern "C"
function fb_hArrayRealloc cdecl ( array as FBARRAY ptr, element_len as size_t, doclear as long, ctor as FB_DEFCTOR, dtor_mult as FB_DTORMULT, dtor as FB_DEFCTOR, dimensions as size_t, ap as va_list ) as long
	dim as size_t i, elements, size
	dim as ssize_t diff
	dim as FBARRAYDIM ptr _dim
	dim as ssize_t lbTB( 0 to FB_MAXDIMENSIONS - 1 )
	dim as ssize_t ubTB( 0 to FB_MAXDIMENSIONS - 1 )
	dim as ubyte ptr this_
	
	/' ditto, see fb_hArrayAlloc() '/
	if ( (dimensions <> array->dimensions) and (array->dimensions <> 0) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' load bounds '/
	for i = 0 to dimensions
		lbTB(i) = cast(ssize_t, va_next( ap, ssize_t ))
		ubTB(i) = cast(ssize_t, va_next( ap, ssize_t ))

		if ( lbTB(i) > ubTB(i) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if
	next

	/' shrinking the array? free unused elements '/

	if ( dtor_mult <> NULL ) then
		dim as size_t new_lb = (ubTB(0) - lbTB(0)) + 1
		if ( new_lb < array->dimTB(0).elements ) then
			/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
			dtor_mult( array, dtor, new_lb )
		end if
	end if

	/' calc size '/
	elements = fb_hArrayCalcElements( dimensions, @lbTB(0), @ubTB(0) )
	diff = fb_hArrayCalcDiff( dimensions, @lbTB(0), @ubTB(0) ) * element_len
	size = elements * element_len

	/' realloc '/
	array->_ptr = realloc( array->_ptr, size )
	if ( array->_ptr = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
	end if

	/' Have remainder? '/
	
	if ( size > array->size ) then
		/' Construct or clear new array elements: '/
		/' Clearing is not needed if not requested, or if ctors will be called
		   (ctors take care of clearing themselves) '/
		this_ = (cast(ubyte ptr,array->_ptr)) + array->size
		if ( ctor ) then
			dim as size_t objects = (size - array->size) / element_len
			while ( objects > 0 )
				/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
				ctor( this_ )

				this_ += element_len
				objects -= 1
			wend
		elseif ( doclear ) then
			memset( cast(any ptr, this_), 0, size - array->size )
		end if
	end if

	DBG_ASSERT( array->element_len = element_len or array->element_len = 0 )
	DBG_ASSERT( array->dimensions = dimensions or array->dimensions = 0 )

	array->data = (cast(ubyte ptr, array->_ptr)) + diff
	array->size = size
	array->element_len = element_len
	array->dimensions = dimensions
	_dim = @array->dimTB(0)
	for i = 0 to dimensions
		_dim->elements = (ubTB(i) - lbTB(i)) + 1
		_dim->lbound = lbTB(i)
		_dim->ubound = ubTB(i)
		_dim += 1
	next

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

private function hRedim cdecl ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ap as va_list ) as long
	dim as FB_DTORMULT dtor_mult

	/' new? '/
	if ( array->_ptr = NULL ) then
		return fb_hArrayAlloc( array, element_len, doclear, NULL, dimensions, ap )
	end if

	/' realloc.. '/
	if ( isvarlen ) then
		dtor_mult = @fb_hArrayDtorStr
	else
		dtor_mult = NULL
	end if

	return fb_hArrayRealloc( array, element_len, doclear, NULL, dtor_mult, NULL, dimensions, ap )
end function

function fb_ArrayRedimPresvEx cdecl ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ... ) as long
	dim as va_list ap
	dim as long res
	
	'va_start( ap, dimensions )
	ap = va_first()
	res = hRedim( array, element_len, doclear, isvarlen, dimensions, ap )
	'va_end( ap )
	
	return res
end function

function fb_ArrayRedimPresv cdecl ( array as FBARRAY ptr, element_len as size_t, isvarlen as long, dimensions as size_t, ... ) as long
	dim as va_list ap
	dim as long res
	
	'va_start( ap, dimensions )
	ap = va_first()
	res = hRedim( array, element_len, TRUE, isvarlen, dimensions, ap )
	'va_end( ap )
	
	return res
end function
end extern