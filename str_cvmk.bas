/' CV# and MK#$ routines '/

#include "fb.bi"

extern "C"
sub hCV cdecl ( _str as FBSTRING ptr, _len as ssize_t, num as any ptr )
	dim as ssize_t i

	if ( _str = NULL ) then
		return
	end if
	
	if ( (_str->data <> NULL) andalso (FB_STRSIZE( _str ) >= _len) ) then
		for i = 0 to _len - 1
			(cast(ubyte ptr, num)[i]) = _str->data[i]
		next
	end if

	/' del if temp '/
	fb_hStrDelTemp( _str )
end sub

function fb_CVD FBCALL ( _str as FBSTRING ptr ) as double
	dim as double num = 0.0
	hCV( _str, sizeof( double ), @num )
	return num
end function

function fb_CVS FBCALL ( _str as FBSTRING ptr ) as single
	dim as single num = 0.0
	hCV( _str, sizeof( single ), @num )
	return num
end function

function fb_CVSHORT FBCALL ( _str as FBSTRING ptr ) as short
	dim as short num = 0
	hCV( _str, sizeof( short ), @num )
	return num
end function

/' 32bit legacy, fbc after 64bit port always calls fb_CVL() or fb_CVLONGINT() '/
function fb_CVI FBCALL ( _str as FBSTRING ptr ) as long
	dim as long num = 0
	hCV( _str, sizeof( long ), @num )
	return num
end function

function fb_CVL FBCALL ( _str as FBSTRING ptr ) as long
	dim as long num = 0
	hCV( _str, sizeof( long ), @num )
	return num
end function

function fb_CVLONGINT FBCALL ( _str as FBSTRING ptr ) as longint
	dim as longint num = 0
	hCV( _str, sizeof( longint ), @num )
	return num
end function

function hMK cdecl ( _len as ssize_t, num as any ptr ) as FBSTRING ptr
	dim as ssize_t i
	dim as FBSTRING ptr dst

	/' alloc temp string '/
    dst = fb_hStrAllocTemp( NULL, _len )
	if ( dst <> NULL ) then
		/' convert '/
		for i = 0 to _len - 1
			dst->data[i] = (cast(ubyte ptr, num))[i]
		next
		
		dst->data[_len] = 0
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

function fb_MKD FBCALL ( num as double ) as FBSTRING ptr
	return hMK( sizeof( double ), @num )
end function

function fb_MKS FBCALL ( num as single ) as FBSTRING ptr
	return hMK( sizeof( single ), @num )
end function

function fb_MKSHORT FBCALL ( num as short ) as FBSTRING ptr
	return hMK( sizeof( short ), @num )
end function

function fb_MKI FBCALL ( num as ssize_t ) as FBSTRING ptr
	return hMK( sizeof( ssize_t ), @num )
end function

function fb_MKL FBCALL ( num as long ) as FBSTRING ptr
	return hMK( sizeof( long ), @num )
end function

function fb_MKLONGINT FBCALL ( num as longint ) as FBSTRING ptr
	return hMK( sizeof( longint ), @num )
end function
end extern