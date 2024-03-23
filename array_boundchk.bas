/' Array bound checking functions '/

#include "fb.bi"

extern "C"
private function hThrowError ( linenum as long, fname as const ubyte ptr ) as any ptr
	/' call user handler if any defined '/
   return cast(any ptr, fb_ErrorThrowEx( FB_RTERROR_OUTOFBOUNDS, linenum, fname, NULL, NULL ))
end function

function fb_ArrayBoundChk FBCALL ( idx as ssize_t, _lbound as ssize_t, _ubound as ssize_t, linenum as long, fname as const ubyte ptr ) as any ptr
	if ( (idx < _lbound) or (idx > _ubound) ) then
		return hThrowError( linenum, fname )
	else
		return NULL
	end if
end function

function fb_ArraySngBoundChk FBCALL ( idx as size_t, _ubound as size_t, linenum as long, fname as const ubyte ptr ) as any ptr
	/' Assuming lbound is 0, we know ubound must be >= 0, and we can treat
	   index as unsigned too, possibly letting it overflow to a very big
	   value (if it was negative), reducing the bound check to a single
	   unsigned comparison. '/
	if ( idx > _ubound ) then
		return hThrowError( linenum, fname )
	else
		return NULL
	end if
end function
end extern