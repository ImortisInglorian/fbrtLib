/' !!!REMOVEME!!! '/
/' descriptor reset, for dynamic local arrays '/

#include "fb.bi"

extern "C"
sub fb_ArrayResetDesc FBCALL ( array as FBARRAY ptr )
	array->data = NULL
	array->_ptr = NULL
	array->size = 0
	array->flags = array->flags and (FBARRAY_FLAGS_DIMENSIONS or FBARRAY_FLAGS_FIXED_DIM or FBARRAY_FLAGS_FIXED_LEN)
	memset( @array->dimTB(0), 0, array->dimensions * sizeof( FBARRAYDIM ) )
end sub
end extern