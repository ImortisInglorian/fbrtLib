/' valwlng function '/

#include "fb.bi"

extern "C"
function fb_WstrToLongint FBCALL ( src as const FB_WCHAR ptr, _len as ssize_t ) as longint
    dim as const FB_WCHAR ptr p, r
	dim as long radix

	/' skip white spc '/
	p = fb_wstr_SkipChar( src, _len, 32 )

	_len -= fb_wstr_CalcDiff( src, p )
	if ( _len < 1 ) then
		return 0
	end if

	radix = 10
	r = p
	if ( (_len >= 2) andalso (*r = asc("&")) ) then
		r += 1
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

		if ( radix <> 10 ) then
			p = r
		end if
	end if

	/' wcstoll() saturates values outside [-2^63, 2^63)
	so use wcstoul() instead '/
	return cast(longint, wcstoull( p, NULL, radix ))
end function

function fb_WstrValLng FBCALL ( _str as const FB_WCHAR ptr ) as longint
    dim as longint _val
	dim as ssize_t _len

	if ( _str = NULL ) then
	    return 0
	end if

	_len = fb_wstr_Len( _str )
	if ( _len = 0 ) then
		_val = 0
	else
		_val = fb_WstrToLongint( _str, _len )
	end if
	return _val
end function
end extern