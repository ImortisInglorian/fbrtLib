'' Array bound checking functions

#include "fb.bi"

extern "C"
private function hThrowError _
	( _
		errnum as long, _
		idx as ssize_t, _
		lbound_ as ssize_t, _
		ubound_ as ssize_t, _
		linenum as long, _
		filename as const ubyte ptr, _
		variablename as const ubyte ptr _
	) as any ptr

	dim as long pos_ = 0
	dim as ubyte msg_buffer(0 to FB_ERRMSG_SIZE-1)
	dim as ubyte ptr msg = @msg_buffer(0)

	pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, !"\n" )

	if( variablename ) then
		pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, _
			"'%s' ", variablename )
	else
		pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, _
			"array " )
	end if

	if( errnum = FB_RTERROR_NOTDIMENSIONED ) then
		pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, _
			!"not dimensioned and array elements are not allocated" )
	elseif( errnum = FB_RTERROR_WRONGDIMENSIONS ) then
		pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, _
			!"accessed with wrong number of dimensions, %" FB_LL_FMTMOD "d given but expected %" FB_LL_FMTMOD "d", _
			cast(longint, idx), cast(longint, ubound_) )
	else
		pos_ += snprintf( @msg[pos_], FB_ERRMSG_SIZE - pos_, _
			!"accessed with invalid index = %" FB_LL_FMTMOD "d, must be between %" FB_LL_FMTMOD "d and %" FB_LL_FMTMOD "d", _
			cast(longint, idx), cast(longint, lbound_), cast(longint, ubound_) )
	end if
	msg[FB_ERRMSG_SIZE-1] = asc(!"\0")

	'' call user handler if any defined
	return cast(any ptr, fb_ErrorThrowMsg( errnum, linenum, filename, msg, NULL, NULL ))
end function

public function fb_ArrayDimensionChk FBCALL _
	( _ 
		byval dimensions as ssize_t, _
		byval array as FBARRAY ptr, _
		byval linenum as long, _
		byval filename as const ubyte ptr, _
		byval variablename as const ubyte ptr _
	) as any ptr

	'' unallocated array
	if( (array = NULL) orelse (array->data = NULL) ) then
		return hThrowError( FB_RTERROR_NOTDIMENSIONED, _
			0, 0, 0, linenum, filename, variablename )
	end if

	'' wrong number of dimensions?
	if( (cast(size_t, dimensions) <> array->dimensions) ) then
		return hThrowError( FB_RTERROR_WRONGDIMENSIONS, _
			dimensions, 0, array->dimensions, linenum, filename, variablename )
	end if

	return NULL
end function

public function fb_ArrayBoundChkEx FBCALL _
	( _
		idx as ssize_t, _
		lbound_ as ssize_t, _
		ubound_ as ssize_t, _
		linenum as long, _
		filename as const ubyte ptr, _
		variablename as const ubyte ptr _
	) as any ptr _

	if ( (idx < lbound_) or (idx > ubound_) ) then
		return hThrowError( FB_RTERROR_OUTOFBOUNDS, idx, lbound_, ubound_, linenum, filename, variablename )
	else
		return NULL
	end if
end function

public function fb_ArraySngBoundChkEx FBCALL ( idx as size_t, ubound_ as size_t, linenum as long, fname as const ubyte ptr, vname as const ubyte ptr ) as any ptr
	/' Assuming lbound is 0, we know ubound must be >= 0, and we can treat
	   index as unsigned too, possibly letting it overflow to a very big
	   value (if it was negative), reducing the bound check to a single
	   unsigned comparison. '/
	if ( idx > ubound_ ) then
		return hThrowError( FB_RTERROR_OUTOFBOUNDS, idx, 0, ubound_, linenum, fname, vname )
	else
		return NULL
	end if
end function

'' legacy, before version 1.20.0
'' these entry points are needed otherwise it is impossible to
'' compile a debug vrsion of newer fbc source from an older fbc
''
public function fb_ArrayBoundChk FBCALL ( idx as ssize_t, lbound_ as ssize_t, ubound_ as ssize_t, linenum as long, filename as const ubyte ptr ) as any ptr
	return fb_ArrayBoundChkEx( idx, lbound_, ubound_, linenum, filename, NULL )
end function

public function fb_ArraySngBoundChk FBCALL ( idx as size_t, ubound_ as size_t, linenum as long, filename as const ubyte ptr ) as any ptr
	return fb_ArraySngBoundChkEx( idx, ubound_, linenum, filename, NULL )
end function

end extern