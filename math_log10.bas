/' integer log base 10 function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IntLog10_32 FBCALL ( x as uinteger ) as integer
	if ( x >= cast(uinteger, 1.E + 9) ) then return 9
	if ( x >= cast(uinteger, 1.E + 8) ) then return 8
	if ( x >= cast(uinteger, 1.E + 7) ) then return 7
	if ( x >= cast(uinteger, 1.E + 6) ) then return 6
	if ( x >= cast(uinteger, 1.E + 5) ) then return 5
	if ( x >= cast(uinteger, 1.E + 4) ) then return 4
	if ( x >= cast(uinteger, 1.E + 3) ) then return 3
	if ( x >= cast(uinteger, 1.E + 2) ) then return 2
	if ( x >= cast(uinteger, 1.E + 1) ) then return 1
	if ( x >= cast(uinteger, 1.E + 0) ) then return 0
	return -1
end function

/':::::'/
function fb_IntLog10_64 FBCALL ( x as ulongint ) as integer
	if ( x and &hffffffff00000000ull ) then
		if ( x >= cast(ulongint, 1.E + 19) ) then return 19
		if ( x >= cast(ulongint, 1.E + 18) ) then return 18
		if ( x >= cast(ulongint, 1.E + 17) ) then return 17
		if ( x >= cast(ulongint, 1.E + 16) ) then return 16
		if ( x >= cast(ulongint, 1.E + 15) ) then return 15
		if ( x >= cast(ulongint, 1.E + 14) ) then return 14
		if ( x >= cast(ulongint, 1.E + 13) ) then return 13
		if ( x >= cast(ulongint, 1.E + 12) ) then return 12
		if ( x >= cast(ulongint, 1.E + 11) ) then return 11
		if ( x >= cast(ulongint, 1.E + 10) ) then return 10
		return 9
	else
		return fb_IntLog10_32( cast(uinteger, x) )
	end if
end function
end extern