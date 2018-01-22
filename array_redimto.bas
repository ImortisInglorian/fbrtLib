/' redim function '/

#include "fb.bi"

extern "C"
function fb_ArrayRedimTo FBCALL ( dest as FBARRAY ptr, source as FBARRAY const ptr, isvarlen as long, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR ) as long
	dim as ssize_t diff
	dim as ubyte ptr this_
	dim as ubyte ptr limit

	if ( dest = source ) then
		return fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	/' ditto, see fb_hArrayAlloc() '/
	if ( (source->dimensions <> dest->dimensions) and (dest->dimensions <> 0) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' Retrieve diff value so we don't have to re-calculate it '/
	if ( source->_ptr > source->data ) then
		diff = (cast(size_t, source->_ptr)) - (cast(size_t, source->data))
		diff = -diff
	else
		/' both may be NULL too '/
		diff = (cast(size_t, source->data)) - (cast(size_t, source->_ptr))
	end if

	/' free old '/
	if ( dtor <> NULL ) then
		fb_ArrayDestructObj( dest, dtor )
	end if
	fb_ArrayErase( dest, isvarlen )

	DBG_ASSERT( dest->element_len = source->element_len or dest->element_len = 0 )
	DBG_ASSERT( dest->dimensions = source->dimensions or dest->dimensions = 0 )

	/' Copy over bounds etc. '/
	dest->size = source->size
	dest->element_len = source->element_len
	dest->dimensions = source->dimensions
	memcpy( @dest->dimTB(0), @source->dimTB(0), sizeof( FBARRAYDIM ) * dest->dimensions )

	/' Empty/unallocated source array? '/
	if ( dest->size = NULL ) then
		/' Destination will be empty/unallocated too '/
		dest->_ptr = NULL
		dest->data = NULL
		return fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	/' Allocate new buffer; clear unless ctors will be called.
	   (ctors take care of clearing themselves) '/
	if ( ctor = NULL ) then
		dest->_ptr = calloc( dest->size, 1 )
	else
		dest->_ptr = malloc( dest->size )
	end if
	if ( dest->_ptr = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
	end if
	dest->data = (cast(ubyte ptr, dest->_ptr)) + diff

	/' Call ctor for each element '/
	if ( ctor <> NULL ) then
		this_ = dest->_ptr
		limit = this_ + dest->size
		while ( this_ < limit )
			ctor( this_ )
			this_ += dest->element_len
		wend
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern