#include "fb.bi"

extern "C"
function fb_hStrRadix2Longint FBCALL ( src as ubyte ptr, _len as ssize_t, radix as long ) as longint
	dim as longint v
	dim as long c

	v = 0

	select case radix 
		/' hex '/
		case 16:
			_len -= 1
			while ( _len >= 0 )
				c = *src
				src += 1
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
				_len -= 1
			wend

		/' oct '/
		case 8:
			_len -= 1
			while ( _len >= 0 )
				c = *src
				src += 1
				if ( (c >= asc("0")) and (c <= asc("7")) ) then
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
				c = *src
				src += 1
				if ( (c >= asc("0")) and (c <= asc("1")) ) then
					v = (v * 2) + (c - 48)
				else
					exit while
				end if
				_len -= 1
			wend

		case else:
			'nothing
	end select

	return v
end function
end extern