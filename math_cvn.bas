/' CV# numeric routines '/

#include "fb.bi"

#macro hDoCVn(from, to_t, size)
	if ( (size) = sizeof(from) and (size) = sizeof(to_t) ) then
		dim as to_t _to
		memcpy( @_to, @from, size )
		return _to
	else
		return cast(to_t, 0)
	end if
#endmacro

function fb_CVDFROMLONGINT FBCALL ( ll as longint ) as double
	hDoCVn( ll, double, 8 )
end function

function fb_CVSFROML FBCALL ( l as integer ) as single
	hDoCVn( l, single, 4 )
end function

function fb_CVLFROMS FBCALL ( f as single ) as integer
	hDoCVn( f, integer, 4 )
end function

function fb_CVLONGINTFROMD FBCALL ( d as double ) as longint
	hDoCVn( d, longint, 8 )
end function
