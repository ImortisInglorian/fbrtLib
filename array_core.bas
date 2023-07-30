/' dynamic arrays core '/

#include "fb.bi"

extern "C"

/' calculate the number of array elements based on the passed
   in to fb_hArrayRealloc().  Note that this is a different
   format than the arrary->dimTB[] table
'/
function fb_hArrayCalcElements ( dimensions as size_t, lboundTB as const ssize_t ptr, uboundTB as const ssize_t ptr ) as size_t
	dim as size_t i, elements

	elements = (uboundTB[0] - lboundTB[0]) + 1
	i = 1
	while( i < dimensions )
		elements *= (uboundTB[i] - lboundTB[i]) + 1
		i += 1
	wend

	return elements
end function

function fb_hArrayCalcDiff ( dimensions as size_t, lboundTB as const ssize_t ptr, uboundTB as const ssize_t ptr ) as ssize_t
	dim as size_t i, elements
	dim as ssize_t diff = 0

	if ( dimensions <= 0 ) then
		return 0
	end if
	
	i = 0
	while( i < dimensions - 1 )
		elements = (uboundTB[i+1] - lboundTB[i+1]) + 1
		diff = (diff + lboundTB[i]) * elements
		i += 1
	wend

	diff += lboundTB[dimensions-1]

	return -diff
end function

function fb_ArrayLen FBCALL ( array as FBARRAY ptr ) as size_t

	if( array ) then
		if( array->_ptr ) then
			return array->size / array->element_len
		end if
	end if
	
	return 0

/'

	Previously, the number of elements was computed from
	the array descriptor's dimensions table.

	scope
		dim as FBARRAYDIM ptr _dim
	
		_dim = @array->dimTB(0)
		elements = _dim->elements
		_dim += 1
	
		i = 1
		while( i < array->dimensions )
			elements *= _dim->elements
			i += 1
			_dim += 1
		wend
		
		return elements
	end scope

'/
end function

function fb_ArraySize FBCALL ( array as FBARRAY ptr ) as size_t 
	if( array ) then
		if( array->_ptr ) then
			return array->size
		end if
	end if
	
	return 0
end function

end extern