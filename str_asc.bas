/' asc function '/

#include "fb.bi"

extern "C"
function fb_ASC FBCALL ( _str as FBSTRING ptr, _pos as ssize_t ) as ulong
    dim a as ulong
	dim _len as ssize_t

	if( _str = NULL ) then
		return 0
	end if 
	
	_len = FB_STRSIZE( _str )
	
	if( (_str->data = NULL) or (_len = 0) or (_pos <= 0) or (_pos > _len) ) then
		a = 0
	else
		a = cast(ubyte, _str->data[_pos-1])
	end if

	/' del if temp '/
	fb_hStrDelTemp( _str )

	return a
end function
end extern