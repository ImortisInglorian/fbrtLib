#include "fb.bi"

extern "C"
function fb_WstrRadix2Int FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t, radix as long ) as long
	dim as long c, v

	v = 0

	select case radix
		/' hex '/
		case 16:
			_len -= 1
			while ( _len >= 0 )
				c = *src + 1
				if ( (c >= 97) and (c <= 102) ) then
					c -= 87
				elseif ( (c >= 65) and (c <= 70) ) then
					c -= 55
				elseif ( (c >= 48) and (c <= 57) ) then
					c -= 48
				else
					exit while
				end if
				
				v = (v * 16) + c
				_len -= 1
			wend

		/' oct '/
		case 8:
			_len -= 1
			while ( _len >= 0 )
				c = *src + 1
				if ( (c >= 48) and (c <= 55) ) then
					v = (v * 8) + (c - 48)
				else
					exit while
				end if
				_len -= 1
			wend

		/' bin '/
		case 2:
			_len -= 1
			while ( _len >= 0 ) 
				c = *src + 1
				if ( (c >= 48) and (c <= 49) ) then
					v = (v * 2) + (c - 48)
				else
					exit while
				end if
				_len -= 1
			wend
	end select

	return v
end function
end extern