/' ERASE for dynamic arrays of objects: destruct elements and free the array '/

#include "fb.bi"

extern "C"
sub fb_hArrayDtorObj ( array as FBARRAY ptr, dtor as FB_DEFCTOR, keep_idx as size_t )
	dim as size_t elements, element_len
	dim as ubyte ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if

	elements = fb_ArrayLen( array )

	/' call dtors in the inverse order '/
	element_len = array->element_len
	this_ = cast(ubyte ptr, (array->_ptr)) + ((elements - 1) * element_len)

	while( elements > keep_idx )
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