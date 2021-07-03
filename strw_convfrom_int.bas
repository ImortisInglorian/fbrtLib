/' valwint function '/

#include "fb.bi"

extern "C"
function fb_WstrToInt FBCALL ( src as const FB_WCHAR ptr, _len as ssize_t ) as long
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
	if ( (_len >= 2) andalso (*r = 38 ) ) then
		r += 1
		select case *r
			case 104, 72: /' h H '/
				r += 1
				radix = 16
			case 111, 79: /' o O '/
				r += 1
				radix = 8
			case 098, 66: /' b B '/
				r += 1
				radix = 2
			case else: /' assume octal '/
				radix = 8
		end select

		if ( radix <> 10 ) then
			p = r
		end if
	end if

	/' wcstol() saturates values outside [-2^31, 2^31)
	so use wcstoul() instead '/
	return wcstoul( p, NULL, radix )
end function

function fb_WstrValInt FBCALL ( _str as const FB_WCHAR ptr ) as long
	dim as ssize_t _len
	dim as long _val

	if ( _str = NULL ) then
	    return 0
	end if

	_len = fb_wstr_Len( _str )
	if ( _len = 0 ) then
		_val = 0
	else
		_val = fb_WstrToInt( _str, _len )
	end if

	return _val
end function
end extern