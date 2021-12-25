/' string deletion function '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_StrDelete FBCALL ( _str as FBSTRING ptr )
	if ( (_str = NULL) orelse (_str->data = NULL) ) then
		return
	end if

	'' Don't free strings we didn't allocate
	if( _str->size <> 0 ) then
		DeAllocate( cast( any ptr, _str->data ) )
	end if

	_str->data = NULL
	_str->len  = 0
	_str->size = 0
end sub
end extern