/' redim function '/

#include "fb.bi"
extern "C"
function fb_hArrayAlloc ( array as FBARRAY ptr, element_len as size_t, doclear as long, ctor as FB_DEFCTOR, dimensions as size_t, ap as cva_list ) as long
	dim as size_t i, elements, size
	dim as ssize_t diff
	dim as FBARRAYDIM ptr _dim
	dim as ssize_t lbTB(0 to FB_MAXDIMENSIONS - 1) = { 0 }
	dim as ssize_t ubTB(0 to FB_MAXDIMENSIONS - 1) = { 0 }

	/' fixed length? '/

	if( array->flags and FBARRAY_FLAGS_FIXED_LEN ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	endif

	/' Must take care with the descriptor's maximum dimensions, because fbc
	   may allocate a smaller descriptor (with room only for some
	   dimensions, but not necessarily all of FB_MAXARRAYDIMS). Thus it's
	   not safe to increase the dimension count of a descriptor.

	   Of course it's not very useful to change the array's dimension count
	   in the first place, because FB's array access syntax depends on the
	   dimension count, and fbc disallows changing it at compile-time in
	   most cases.

	   The situation where fbc can't know the exact dimensions is with
	   <dim array()> where there's no dimension count given in the
	   declaration. If fbc can't figure out the dimension count later during
	   the compilation, then it has to allocate a descriptor with room for
	   FB_MAXARRAYDIMS and initialize its FBARRAY.dimension field to 0.
	   Then, if we see the 0 here, we know that there's room for
	   FB_MAXARRAYDIMS, and can initialize the descriptor for its first use.
	   Once this initial dimension count has been set, it can't be changed
	   anymore, because the descriptor from then on looks like it only has
	   room for that first-used amount of dimensions. Any unused dimensions
	   will be wasted memory of course.

	   Thus overall it's best to disallow changing the dimension count at
	   runtime completely, except for the first-use case where fbc couldn't
	   figure out the dimensions at compile-time. '/
	if ( (dimensions <> array->dimensions) and (array->dimensions <> 0) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' load bounds '/
	_dim = @array->dimTB(0)
	i = 0
	while( i < dimensions )
		lbTB(i) = cast(ssize_t, cva_arg( ap, ssize_t ))
		ubTB(i) = cast(ssize_t, cva_arg( ap, ssize_t ))
		
		if ( lbTB(i) > ubTB(i) ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		end if

		_dim->elements = (ubTB(i) - lbTB(i)) + 1
		_dim->lbound = lbTB(i)
		_dim->ubound = ubTB(i)
		_dim += 1
		i += 1
	wend
	
	/' calc size '/
	elements = fb_hArrayCalcElements( dimensions, @lbTB(0), @ubTB(0) )
	diff = fb_hArrayCalcDiff( dimensions, @lbTB(0), @ubTB(0) ) * element_len
	size = elements * element_len

	/' Allocte new buffer '/
	/' Clearing is not needed if not requested, or if ctors will be called
	   (ctors take care of clearing themselves) '/
	if ( (doclear = 32) and (ctor = NULL) ) then
		array->_ptr = malloc( size )
		memset( array->_ptr, 32, size )  
	elseif ( (doclear <> 0) and (ctor = NULL) ) then
		array->_ptr = calloc( size, 1 )
	else
		array->_ptr = malloc( size )
	end if

	if ( array->_ptr = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
	end if

	/' call ctor for each element '/
	if ( ctor <> 0 ) then
		dim as ubyte ptr this_ = array->_ptr
		while( elements > 0 )
			/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
			ctor( this_ )
			
			this_ += element_len
			elements -= 1
		wend
	end if

	DBG_ASSERT( array->element_len = element_len or array->element_len = 0 )
	DBG_ASSERT( array->dimensions = dimensions or array->dimensions = 0 )

	array->data = (cast(ubyte ptr, array->_ptr)) + diff
	array->size = size
	array->element_len = element_len
	array->dimensions = dimensions

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function hRedim ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ap as cva_list ) as long
	/' free old '/
	if( isvarlen ) then
		fb_ArrayStrErase( array )
	else
		fb_ArrayErase( array )
	end if
	
   return fb_hArrayAlloc( array, element_len, doclear, NULL, dimensions, ap )
end function

function fb_ArrayRedimEx ( array as FBARRAY ptr, element_len as size_t, doclear as long, isvarlen as long, dimensions as size_t, ... ) as long
	dim as cva_list ap
	dim as long res

	cva_start( ap, dimensions )
	res = hRedim( array, element_len, doclear, isvarlen, dimensions, ap )
	cva_end( ap )
	
	return res
end function 

end extern