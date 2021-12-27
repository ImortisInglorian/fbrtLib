/' string length function '/

#include "fb.bi"

extern "C"
function fb_StrLen FBCALL ( _str as any ptr, str_size as ssize_t ) as ssize_t
	dim as ssize_t _len

	if ( _str = NULL ) then
		return 0
	end if

	/' is dst var-len? '/
	if ( str_size = -1 ) then
		_len = FB_STRSIZE( _str )
	else
		/' this routine will never be called for fixed-len strings, as
		   their sizes are known at compiler-time, as such, this must be
		   a zstring, so find out the real len (as in C/PB) '/
		_len = strlen( cast(ubyte ptr,_str) )
	end if

	return _len
end function
end extern