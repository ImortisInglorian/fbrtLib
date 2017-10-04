/' fix function for singles and doubles FIX( x ) = SGN( x ) * INT( ABS( x ) ) '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
/':::::'/
function fb_FIXSingle FBCALL ( x as single ) as single
	return floorf(fabsf( x )) * fb_SGNSingle( x )
end function

/':::::'/
function fb_FIXDouble FBCALL ( x as double ) as double
	return floor( fabs( x ) ) * fb_SGNDouble( x )
end function
end extern