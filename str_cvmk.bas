/' CV# and MK#$ routines '/

#include "fb.bi"
#include "destruct_string.bi"

sub hCV ( _str as FBSTRING ptr, _len as ssize_t, num as any ptr )
	dim as ssize_t i

	if ( _str = NULL ) then
		return
	end if
	
	if ( (_str->data <> NULL) andalso (FB_STRSIZE( _str ) >= _len) ) then
		for i = 0 to _len - 1
			(cast(ubyte ptr, num)[i]) = _str->data[i]
		next
	end if
end sub

function hMK ( _len as ssize_t, num as any ptr, result as FBSTRING ptr ) as FBSTRING ptr
	dim as ssize_t i
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
		dim as ubyte ptr dst_data = dst.data
		/' convert '/
		for i = 0 to _len - 1
			dst_data[i] = (cast(ubyte ptr, num))[i]
		next
		
		dst_data[_len] = 0
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function

extern "C"
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

function fb_MKD FBCALL ( num as double, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( double ), @num, result )
end function

function fb_MKS FBCALL ( num as single, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( single ), @num, result )
end function

function fb_MKSHORT FBCALL ( num as short, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( short ), @num, result )
end function

function fb_MKI FBCALL ( num as ssize_t, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( ssize_t ), @num, result )
end function

function fb_MKL FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( long ), @num, result )
end function

function fb_MKLONGINT FBCALL ( num as longint, result as FBSTRING ptr ) as FBSTRING ptr
	return hMK( sizeof( longint ), @num, result )
end function
end extern