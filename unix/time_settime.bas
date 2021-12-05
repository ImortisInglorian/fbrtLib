#include "../fb.bi"
#include "sys/time.bi"

Extern "c"
Function fb_hSetTime( h as long, m as long, s as long ) as long

	dim tv as timeval
	gettimeofday( @tv, NULL )
	tv.tv_sec -= (tv.tv_sec Mod 86400)
	tv.tv_sec += (h * 3600) + (m * 60) + s
	if( settimeofday( @tv, NULL ) ) then
		return -1
	end if
	return 0
End Function
End Extern
