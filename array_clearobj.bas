/' ERASE for static arrays of objects: re-init the elements '/

#include "fb.bi"

extern "C"
sub fb_hArrayCtorObj( array as FBARRAY ptr, ctor as FB_DEFCTOR )
	dim as size_t elements, element_len
	dim as ubyte ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if
	
	elements = fb_ArrayLen( array )

	/' call ctors '/
	element_len = array->element_len
	this_ = array->_ptr

	while( elements > 0 )
		/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
		ctor( this_ )
		this_ += element_len
		elements -= 1
	wend
end sub

function fb_ArrayClearObj FBCALL ( array as FBARRAY ptr, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long
	/' destruct all objects in the array
	   (dtor can be NULL if there only is a ctor) '/
	if ( dtor <> 0 ) then
		fb_ArrayDestructObj( array, dtor )
	end if

	/' re-initialize (ctor can be NULL if there only is a dtor) '/
	if( ctor <> 0) then
		/' if a ctor exists, it should handle the whole initialization '/
		fb_hArrayCtorObj( array, ctor )
	else
		/' otherwise, just clear '/
		fb_ArrayClear( array )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern