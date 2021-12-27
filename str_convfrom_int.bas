/' valint function '/

#include "fb.bi"

extern "C"
function fb_hStr2Int FBCALL ( src as ubyte ptr, _len as ssize_t ) as long
	dim as ubyte ptr p
	dim as long radix, skip

	/' skip white spc '/
	p = fb_hStrSkipChar( src, _len, asc(" ") )

	_len -= cast(ssize_t, p - src)
	if ( _len < 1 ) then
		return 0
	elseif ( (_len >= 2) and (p[0] = asc("&")) ) then 
		radix = 0
		skip = 2
		select case p[1]
			case asc("h"), asc("H"):
				radix = 16
			case asc("o"), asc("O"):
				radix = 8
			case asc("b"), asc("B"):
				radix = 2
			case else: /' assume octal '/
				radix = 8
				skip = 1
		end select

		if ( radix <> 0 ) then
			return fb_hStrRadix2Int( @p[skip], _len - skip, radix )
		end if
	end if

	/' atoi() saturates values outside [-2^31, 2^31)
	so use strtoul() instead '/
	return strtoul( p, NULL, 10 )
end function

function fb_VALINT FBCALL ( _str as FBSTRING ptr ) as long
	dim as long _val

	if ( _str = NULL ) then
		return 0
	end if
	if ( (_str->data = NULL) or (FB_STRSIZE( _str ) = 0) ) then
		_val = 0
	else
		_val = fb_hStr2Int( _str->data, FB_STRSIZE( _str ) )
	end if

	return _val
end function
end extern