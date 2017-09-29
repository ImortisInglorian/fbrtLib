/' frac( x ) = x - fix( x )  - returns the fractional part of a float '/

#include "fb.bi"

function fb_FRACf FBCALL ( x as single ) as single
	return x - fb_FIXSingle( x )
end function

function fb_FRACd FBCALL ( x as double ) as double
	return x - fb_FIXDouble( x )
end function