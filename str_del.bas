/' string deletion function '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_StrDelete FBCALL ( _str as FBSTRING ptr )
    if ( (_str = NULL) or (_str->data = NULL) ) then
    	return
	end if
	
    free( cast( any ptr, _str->data ) )

	_str->data = NULL
	_str->len  = 0
	_str->size = 0
end sub
end extern