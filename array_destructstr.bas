/' ERASE for dynamic arrays of var-len strings '/

#include "fb.bi"

extern "C"
sub fb_hArrayDtorStr ( array as FBARRAY ptr, dtor as FB_DEFCTOR, base_idx as size_t )
	dim as size_t i
	dim as ssize_t elements
	dim as FBARRAYDIM ptr _dim
	dim as FBSTRING ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if

	_dim = @array->dimTB(0)
	elements = _dim->elements - base_idx
	_dim += 1

	i = 1
	while( i < array->dimensions )
		elements *= _dim->elements
		i += 1
		_dim += 1
	wend

	/' call dtors in the inverse order '/
	this_ = cast(FBSTRING ptr, array->_ptr) + (base_idx + (elements-1))

	while( elements > 0 )
		if ( this_->data <> NULL ) then
			fb_StrDelete( this_ )
		end if
		this_ -= 1
		elements -= 1
	wend
end sub

sub fb_ArrayDestructStr FBCALL ( array as FBARRAY ptr )
	fb_hArrayDtorStr( array, NULL, 0 )
end sub
end extern