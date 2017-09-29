/' SGN function '/

#include "fb.bi"


/':::::'/
function fb_SGNb FBCALL ( x as ubyte ) as integer
	if ( x = 0 ) then
		return 0
	elseif ( x > 0 ) then
		return 1
	else
		return -1
	end if
end function

/':::::'/
function fb_SGNi FBCALL ( x as integer ) as integer
	if ( x = 0 ) then
		return 0
	elseif ( x > 0 ) then
		return 1
	else
		return -1
	end if
end function

/':::::'/
function fb_SGNl FBCALL ( x as longint ) as integer
	if ( x = 0 ) then
		return 0ll
	elseif ( x > 0ll ) then
		return 1
	else
		return -1
	end if
end function

/':::::'/
function fb_SGNSingle FBCALL ( x as single ) as integer
	if ( x = 0.0 ) then
		return 0
	elseif ( x > 0.0 ) then
		return 1
	else
		return -1
	end if
end function

/':::::'/
function fb_SGNDouble FBCALL ( x as double ) as integer
	if ( x = 0.0 ) then
		return 0
	elseif ( x > 0.0 ) then
		return 1
	else
		return -1
	end if
end function