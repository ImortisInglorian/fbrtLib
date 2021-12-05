#include "../fb.bi"
#include "sys/time.bi"

Extern "c"
Function fb_hSetDate( int y, int m, int d ) as long

	dim month_len(0 To 11) as const long = _
	{ _
		2678400, 2419200, 2678400, 2592000, 2678400, 2592000, _
		2678400, 2678400, 2592000, 2678400, 2592000, 2678400 _
	}

	dim tv as timeval
	dim secs as time_t
	dim i as long

	if( y < 1970 ) then
		return -1
	end if
	gettimeofday( @tv, NULL )
	secs = tv.tv_sec Mod 86400
	tv.tv_sec = 0
	for i = 1970 to y - 1
		tv.tv_sec += 31536000
		if( ((i Mod 4) = 0) OrElse ((i / 400) = 0) ) then
			d += 1
		end if
	Next
	tv.tv_sec += (m * month_len(m-1))
	if( ((y Mod 4) = 0) OrElse ((y / 400) = 0) ) then
		d += 1
	end if
	tv.tv_sec += (d * 86400) + secs
	if( settimeofday( @tv, NULL ) ) then
		return -1
	end if

	return 0
End Function
End Extern

