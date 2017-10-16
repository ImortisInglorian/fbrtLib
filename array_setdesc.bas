/' !!!REMOVEME!!! '/
/' descriptor set, for non-dynamic local arrays '/

#include "fb.bi"

extern "C"
sub fb_ArraySetDesc cdecl ( array as FBARRAY ptr, _ptr as any ptr, element_len as size_t, dimensions as size_t, ... )
    dim as va_list ap
	dim as size_t i, elements
	dim as ssize_t diff
    dim as FBARRAYDIM ptr _dim
	dim as ssize_t lbTB(0 to FB_MAXDIMENSIONS - 1)
	dim as ssize_t ubTB(0 to FB_MAXDIMENSIONS - 1)

    'va_start( ap, dimensions )
	ap = va_first()
    _dim = @array->dimTB(0)

    for i = 0 to dimensions
		lbTB(i) = cast(ssize_t, va_next( ap, ssize_t ))
		ubTB(i) = cast(ssize_t, va_next( ap, ssize_t ))

    	_dim->elements = (ubTB(i) - lbTB(i)) + 1
    	_dim->lbound = lbTB(i)
    	_dim->ubound = ubTB(i)
    	_dim += 1
    next

    'va_end( ap );

    elements = fb_hArrayCalcElements( dimensions, @lbTB(0), @ubTB(0) )
    diff = fb_hArrayCalcDiff( dimensions, @lbTB(0), @ubTB(0) ) * element_len

	array->data = (cast(ubyte ptr, _ptr)) + diff
	array->_ptr = _ptr
	array->size = elements * element_len
	array->element_len = element_len
	array->dimensions = dimensions
end sub
end extern