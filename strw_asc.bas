/' ascw function '/

#include "fb.bi"

extern "C"
function fb_WstrAsc FBCALL ( _str as FB_WCHAR const ptr, _pos as ssize_t ) as ulong
	dim as ssize_t _len

	if ( _str = NULL ) then
		return 0
	end if

	_len = fb_wstr_Len( _str )
	if ( (_len = 0) or (_pos <= 0) or (_pos > _len) ) then
		return 0
	else
		return _str[_pos-1]
	end if
end function
end extern