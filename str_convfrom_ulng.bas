/' valulng function '/

#include "fb.bi"
extern "C"
function fb_hStr2ULongint FBCALL ( src as ubyte ptr, _len as ssize_t ) as ulongint
    dim as ubyte ptr p
	dim as long radix, skip

	/' skip white spc '/
	p = fb_hStrSkipChar( src, _len, 32 )

	_len -= cast(ssize_t, p - src)
	if ( _len < 1 ) then
		return 0
	end if
	
	radix = 10
	if ( (_len >= 2) and (p[0] = asc( "&" )) ) then
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

		if ( radix <> 10 ) then
			p += skip
		end if
	end if

	return strtoull( p, NULL, radix )
end function

/':::::'/
function fb_VALULNG FBCALL ( _str as FBSTRING ptr ) as ulongint
    dim as ulongint _val

	if ( _str = NULL ) then
	    return 0
	end if

	if ( (_str->data = NULL) orelse (FB_STRSIZE( _str ) = 0) ) then
		_val = 0
	else
		_val = fb_hStr2ULongint( _str->data, FB_STRSIZE( _str ) )
	end if

	/' del if temp '/
	fb_hStrDelTemp( _str )

	return _val
end function
end extern