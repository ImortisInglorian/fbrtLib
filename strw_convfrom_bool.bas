/' valbool (wstring) function (boolean) '/

#include "fb.bi"

extern "C"
private function w_cmp( a as const FB_WCHAR ptr, _len as ssize_t, z as FB_WCHAR ptr ) as long
	dim as ssize_t chars, i

	chars = fb_wstr_Len( z )

	if ( chars <> _len ) then
		return 1
	end if
	
	for i = 0 to chars - 1
		if ( fb_wstr_ToUpper( *a ) <> fb_wstr_ToUpper( *z ) ) then
			return 1
		end if

		a += 1
		z += 1
	next

	return 0
end function


/' convert wstring to boolean value
 *  
 * return value must be 0|1
 *
 '/
function fb_WstrToBool FBCALL ( src as const FB_WCHAR ptr, _len as ssize_t ) as ubyte
	dim as double _val

	if ( w_cmp( src, _len, fb_hBoolToWstr( FALSE ) ) = 0 ) then
		return 0
	end if

	if ( w_cmp( src, _len, fb_hBoolToWstr( TRUE ) ) = 0 ) then
		return 1
	end if

	_val = fb_WstrToDouble( src, _len )

	if ( (_val <> cast(double, (0.0)) ) and (_val <> cast(double, (-0.0))) ) then
		return 1
	end if

	return 0
end function

/':::::'/
function fb_WstrValBool FBCALL ( _str as const FB_WCHAR ptr ) as ubyte
	dim as ssize_t _len
	dim as long _val

	if ( _str = NULL ) then
	    return 0
	end if

	_len = fb_wstr_Len( _str )
	if ( _len = 0 ) then
		_val = 0
	else
		_val = fb_WstrToBool( _str, _len )
	end if
	
	return _val
end function
end extern