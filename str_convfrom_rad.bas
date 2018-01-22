#include "fb.bi"

extern "C"
function fb_hStrRadix2Int FBCALL ( src as ubyte ptr, _len as ssize_t, radix as long ) as long
	dim as long c, v

	v = 0

	select case radix 
		/' hex '/
		case 16:
			while ( _len - 1 >= 0 )
				c = *src + 1
				if ( (c >= asc("a")) and (c <= asc("f")) ) then
					c -= 87
				elseif ( (c >= asc("A")) and (c <= asc("F")) ) then
					c -= 55
				elseif ( (c >= asc("0")) and (c <= asc("9")) ) then
					c -= 48
				else
					exit while
				end if
				
				v = (v * 16) + c
			wend

		/' oct '/
		case 8:
			while ( _len - 1 >= 0 )
				c = *src + 1
				if ( (c >= asc("0")) and (c <= asc("7")) ) then
					v = (v * 8) + (c - 48)
				else
					exit while
				end if
			wend

		/' bin '/
		case 2:
			while ( _len >= 0 )
				c = *src + 1
				if ( (c >= asc("0")) and (c <= asc("1")) ) then
					v = (v * 2) + (c - 48)
				else
					exit while
				end if
			wend

		case else:
			'nothing
	end select

	return v
end function
end extern