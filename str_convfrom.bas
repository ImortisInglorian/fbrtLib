/' val function '/

#include "fb.bi"

extern "C"
function fb_hStr2Double FBCALL ( src as ubyte ptr, _len as ssize_t ) as double
	dim as ubyte ptr p, q, c
	dim as long radix, i, skip
	dim as double ret

	/' skip white spc '/
	p = fb_hStrSkipChar( src, _len, asc(" ") )

	_len -= cast(ssize_t, p - src)
	if ( _len < 1 ) then
		return 0.0
	elseif ( _len >= 2 ) then
		if ( p[0] = asc("&") ) then
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

			return fb_hStrRadix2Longint( p + skip, _len - skip, radix )

		elseif ( p[0] = 0 ) then
			if ( p[1] = asc("x") or p[1] = asc("X") )  then
				/' Filter out strings with 0x/0X prefix -- strtod() treats them as hex.
				   But we only want to support the &h prefix for that. '/
				return 0.0 /' 0x would be parsed to the value zero '/
			end if
		end if
	end if

	/' Workaround: strtod() does not allow 'd' as an exponent specifier on 
	 * non-win32 platforms, so create a temporary buffer and replace any 
	 * 'd's with 'e'.
	 * This would be bad for hex strings, but those should be handled above already.
	 '/
	q = malloc( _len + 1 )
	for i = 0 to _len - 1
		c = @p[i]
		if ( c = asc("d") or c = asc("D") ) then
			c += 1
		end if
		q[i] = *c
	next
	q[_len] = 0

	ret = strtod( q, NULL )
	free( q )

	return ret
end function

function fb_VAL FBCALL ( _str as FBSTRING ptr ) as double
	dim as double _val

	if ( _str = NULL ) then
		return 0.0
	end if
	if ( (_str->data = NULL) or (FB_STRSIZE( _str ) = 0) ) then
		_val = 0.0
	else
		_val = fb_hStr2Double( _str->data, FB_STRSIZE( _str ) )
	end if
	/' del if temp '/
	fb_hStrDelTemp( _str )

	return _val
end function
end extern