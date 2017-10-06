/' val function '/

#include "fb.bi"

extern "C"
function fb_hStr2Double FBCALL ( src as ubyte ptr, _len as ssize_t ) as double
	dim as ubyte ptr p, q, c
	dim as long radix, i, skip
	dim as double ret

	/' skip white spc '/
	p = fb_hStrSkipChar( src, _len, 32 )

	_len -= cast(ssize_t, p - src)
	if ( _len < 1 ) then
		return 0.0
	elseif ( _len >= 2 ) then
		if ( p[0] = 38 ) then '&
			skip = 2
			select case p[1]
				case 72 or 104: 'h or H
					radix = 16
				case 79 or 111: 'o or O
					radix = 8
				case 66 or 98: 'b or B
					radix = 2
				case else: /' assume octal '/
					radix = 8
					skip = 1
			end select

			return fb_hStrRadix2Longint( p + skip, _len - skip, radix )

		elseif ( p[0] = 0 ) then
			if ( p[1] = 88 or p[1] = 120 )  then 'x or X
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
	for i = 0 to _len
		c = @p[i]
		if ( c = 68 or c = 100 ) then 'd or D
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