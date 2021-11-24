/' valw function '/

#include "fb.bi"

extern "C"
function fb_WstrToDouble FBCALL ( src as const FB_WCHAR ptr, _len as ssize_t ) as double
	dim as const FB_WCHAR ptr p, r
	dim as long radix
	dim as ssize_t i
	dim as FB_WCHAR ptr q
	dim as FB_WCHAR c
	dim as double ret

	/' skip white spc '/
	p = fb_wstr_SkipChar( src, _len, asc(" ") )

	_len -= fb_wstr_CalcDiff( src, p )
	if ( _len < 1 ) then
		return 0.0
	end if

	r = p
	if ( (_len >= 2) andalso (*r = asc("&")) ) then
		r += 1
		radix = 0
		select case *r
			case asc("h"), asc("H"):
				r += 1
				radix = 16
			case asc("o"), asc("O"):
				r += 1
				radix = 8
			case asc("b"), asc("B"):
				r += 1
				radix = 2
			case else: /' assume octal '/
				radix = 8
		end select

		if ( radix <> 0 ) then
			return cast(double, fb_WstrRadix2Longint( r, _len - fb_wstr_CalcDiff( p, r ), radix ))
		end if
	end if

	/' Workaround: wcstod() does not allow 'd' as an exponent specifier on 
	 * non-win32 platforms, so create a temporary buffer and replace any 
	 * 'd's with 'e'
	 '/
	q = New FB_WCHAR[_len + 1]
	i = 0
	while( i < _len )
		c = p[i]
		if ( c = asc("d") orelse c = asc("D") ) then /' d D '/
			c += 1
		end if
		q[i]= c
		i += 1
	wend
	q[_len] = 0
	ret = wcstod( q, NULL )
	Delete [] q

	return ret
end function

function fb_WstrVal FBCALL ( _str as const FB_WCHAR ptr ) as double
    dim as double _val
	dim as ssize_t _len

	if ( _str = NULL ) then
	    return 0.0
	end if

	_len = fb_wstr_Len( _str )
	if ( _len = 0 ) then
		_val = 0.0
	else
		_val = fb_WstrToDouble( _str, _len )
	end if

	return _val
end function
end extern