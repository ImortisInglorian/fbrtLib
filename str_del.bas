/' string deletion function '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_StrDelete FBCALL ( _str as FBSTRING ptr )
    if ( (_str = NULL) or (_str->_data = NULL) ) then
    	return
	end if
	
    free( cast( any ptr, _str->_data ) )

	_str->_data = NULL
	_str->_len  = 0
	_str->size = 0
end sub
end extern