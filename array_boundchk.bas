/' Array bound checking functions '/

#include "fb.bi"

extern "C"
private function hThrowError _
	( _
		idx as ssize_t, _
		lbound_ as ssize_t, _
		ubound_ as ssize_t, _
		linenum as long, _
		fname as const ubyte ptr, _
		vname as const ubyte ptr _
	) as any ptr

	dim as ubyte msg( 0 to FB_ERRMSG_SIZE-1 )
	snprintf( @msg(0), FB_ERRMSG_SIZE, _
		"%s -> wrong index = %" + FB_LL_FMTMOD + "d, lbound = %" + FB_LL_FMTMOD + "d, ubound = %" + FB_LL_FMTMOD + "d", _
		vname, cast(longint, idx), cast(longint, lbound_), cast(longint, ubound_) )
	msg(FB_ERRMSG_SIZE-1) = asc("!\0")

	/' call user handler if any defined '/
   return cast(any ptr, fb_ErrorThrowMsg( FB_RTERROR_OUTOFBOUNDS, linenum, fname, @msg(0), NULL, NULL ))
end function

function fb_ArrayBoundChkEx FBCALL ( idx as ssize_t, lbound_ as ssize_t, ubound_ as ssize_t, linenum as long, fname as const ubyte ptr, vname as const ubyte ptr ) as any ptr
	if ( (idx < lbound_) or (idx > ubound_) ) then
		return hThrowError( idx, lbound_, ubound_, linenum, fname, vname )
	else
		return NULL
	end if
end function

function fb_ArraySngBoundChkEx FBCALL ( idx as size_t, ubound_ as size_t, linenum as long, fname as const ubyte ptr, vname as const ubyte ptr ) as any ptr
	/' Assuming lbound is 0, we know ubound must be >= 0, and we can treat
	   index as unsigned too, possibly letting it overflow to a very big
	   value (if it was negative), reducing the bound check to a single
	   unsigned comparison. '/
	if ( idx > ubound_ ) then
		return hThrowError( idx, 0, ubound_, linenum, fname, vname )
	else
		return NULL
	end if
end function

function fb_ArrayBoundChk FBCALL ( idx as ssize_t, lbound_ as ssize_t, ubound_ as ssize_t, linenum as long, fname as const ubyte ptr ) as any ptr
	if ( (idx < lbound_) or (idx > ubound_) ) then
		return hThrowError( idx, lbound_, ubound_, linenum, fname, NULL )
	else
		return NULL
	end if
end function

function fb_ArraySngBoundChk FBCALL ( idx as size_t, ubound_ as size_t, linenum as long, fname as const ubyte ptr ) as any ptr
	/' Assuming lbound is 0, we know ubound must be >= 0, and we can treat
	   index as unsigned too, possibly letting it overflow to a very big
	   value (if it was negative), reducing the bound check to a single
	   unsigned comparison. '/
	if ( idx > ubound_ ) then
		return hThrowError( idx, 0, ubound_, linenum, fname, NULL )
	else
		return NULL
	end if
end function
end extern