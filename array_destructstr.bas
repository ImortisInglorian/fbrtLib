/' ERASE for dynamic arrays of var-len strings '/

#include "fb.bi"

extern "C"
sub fb_hArrayDtorStr ( array as FBARRAY ptr, dtor as FB_DEFCTOR, keep_idx as size_t )
	dim as size_t elements
	dim as FBSTRING ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if

	elements = fb_ArrayLen( array )

	/' call dtors in the inverse order '/
	this_ = cast(FBSTRING ptr, array->_ptr) + (elements-1)

	while( elements > keep_idx )
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