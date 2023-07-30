#include "fb.bi"

extern "C"
function fb_hStrSkipChar FBCALL ( s as ubyte ptr, _len as ssize_t, c as long ) as ubyte ptr
	dim as ubyte ptr p = s

	if ( s <> NULL ) then
		_len -= 1
		while ( (_len >= 0) and (cast(long, *p) = c) )
			p += 1
			_len -= 1
		wend
	end if
    return p
end function

function fb_hStrSkipCharRev FBCALL ( s as ubyte ptr, _len as ssize_t, c as long ) as ubyte ptr
	dim as ubyte ptr p

	if ( (s = NULL) or (_len <= 0) ) then
		return s
	end if

	p = @s[_len-1]

	/' fixed-len's are filled with null's as in PB, strip them too '/
	_len -= 1
	while ( (_len >= 0) and ((cast(long, *p) = c) or (cast(long, *p) = 0) ) )
		p -= 1
		_len -= 1
	wend

	return p
end function
end extern