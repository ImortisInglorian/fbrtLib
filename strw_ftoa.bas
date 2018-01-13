/' float to wstring, internal usage '/

#include "fb.bi"

extern "C"
function fb_FloatExToWstr( _val as double, buffer as FB_WCHAR ptr, digits as long, mask as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr p
	dim as ssize_t _len

	if( mask and FB_F2A_ADDBLANK ) then
		p = @buffer[1]
	else
		p = buffer
	end if

	swprintf( p, cast(wchar_t ptr, 16+8+1), sadd("%.*g"), digits, _val )

	_len = fb_wstr_Len( p )

	if ( _len > 0 ) then
		/' skip the dot at end if any '/
		if ( _len > 0 ) then
			if ( p[_len-1] = 46 ) then
				p[_len-1] = 0
			end if
		end if
	end if

	/' '/
	if ( (mask and FB_F2A_ADDBLANK) > 0 ) then
		if ( *p <> 45 ) then
			*buffer = 32
			return buffer
		else
			return p
		end if
	else
		return p
	end if
end function
end extern