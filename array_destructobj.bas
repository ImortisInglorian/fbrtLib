/' ERASE for dynamic arrays of objects: destruct elements and free the array '/

#include "fb.bi"

extern "C"
sub fb_hArrayDtorObj cdecl ( array as FBARRAY ptr, dtor as FB_DEFCTOR, base_idx as size_t )
	dim as size_t i, elements, element_len
	dim as FBARRAYDIM ptr _dim
	dim as ubyte ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if

    _dim = @array->dimTB(0)
    elements = _dim->elements - base_idx
    _dim += 1

    for i = 1 to array->dimensions
	   	elements *= _dim->elements
		_dim += 1
	next

	/' call dtors in the inverse order '/
	element_len = array->element_len
	this_ = cast(ubyte ptr, (array->_ptr) + ((base_idx + (elements-1)) * element_len))

	while( elements > 0 )
		/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
		dtor( this_ )
		this_ -= element_len
		elements -= 1
	wend
end sub

sub fb_ArrayDestructObj FBCALL ( array as FBARRAY ptr, dtor as FB_DEFCTOR )
	fb_hArrayDtorObj( array, dtor, 0 )
end sub
end extern