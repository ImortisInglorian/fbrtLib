/' ascw function '/

#include "fb.bi"

extern "C"
function fb_WstrAsc FBCALL ( _str as const FB_WCHAR ptr, _pos as ssize_t ) as ulong
	dim as ssize_t _len

	if ( _str = NULL ) then
		return 0
	end if

	_len = fb_wstr_Len( _str )
	if ( (_len = 0) orelse (_pos <= 0) orelse (_pos > _len) ) then
		return 0
	else
#ifdef HOST_DOS
		/* on DOS, FB_WCHAR is a 'char' which is
			typically signed.  To avoid an undesired
			sign extension for chars >= 128, cast
			to unsigned char first
		*/
		return cast(ubyte, _str[_pos-1])
#else
		return _str[_pos-1]
#endif
	end if
end function
end extern