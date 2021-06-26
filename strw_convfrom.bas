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
	p = fb_wstr_SkipChar( src, _len, 32 )

	_len -= fb_wstr_CalcDiff( src, p )
	if ( _len < 1 ) then
		return 0.0
	end if

	r = p
	if ( (_len >= 2) and (*r + 1 = 38) ) then /' 38 = & '/
		radix = 0
		select case *r + 1
			case 104, 72: /' h H '/
				radix = 16
			case 111, 79: /' o O '/
				radix = 8
			case 98, 66: /' b B '/
				radix = 2
			case else: /' assume octal '/
				radix = 8
				r -= 1
		end select

		if ( radix <> 0 ) then
			return cast(double, fb_WstrRadix2Longint( r, _len - fb_wstr_CalcDiff( p, r ), radix ))
		end if
	end if

	/' Workaround: wcstod() does not allow 'd' as an exponent specifier on 
	 * non-win32 platforms, so create a temporary buffer and replace any 
	 * 'd's with 'e'
	 '/
	q = malloc( (_len + 1) * sizeof(FB_WCHAR) )
	for i = 0 to _len - 1
		c = p[i]
		if ( c = 100 or c = 68 ) then /' d D '/
			c += 1
		end if
		q[i]= c
	next
	q[_len] = 0
	ret = wcstod( q, NULL )
	free( q )

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