/'  valbool (string) function (boolean)  '/

#include "fb.bi"


/'' convert string to boolean value
 *  
 * return value must be 0|1
 *
 '/
 
 extern "C"
function fb_hStr2Bool FBCALL ( src as ubyte ptr, _len as ssize_t ) as ubyte
	dim as double _val

	if ( strcasecmp( src, fb_hBoolToStr( FALSE ) )=0 ) then
		return 0
	end if
	if ( strcasecmp( src, fb_hBoolToStr( TRUE ) )=0 ) then
		return 1
	end if
	_val = fb_hStr2Double( src, _len )

	if ( (_val <> cast(double, 0.0) ) and (_val <> cast(double, -0.0)) ) then
		return 1
	end if
	return 0
end function

/':::::'/
function fb_VALBOOL FBCALL ( _str as FBSTRING ptr ) as ubyte
	dim as long _val

	if ( _str = NULL ) then
		return 0
	end if
	if ( (_str->data = NULL) or (FB_STRSIZE( _str ) = 0) ) then
		_val = 0
	else
		_val = fb_hStr2Bool( _str->data, FB_STRSIZE( _str ) )
	end if
	/' del if temp '/
	fb_hStrDelTemp( _str )

	return _val
end function
end extern
