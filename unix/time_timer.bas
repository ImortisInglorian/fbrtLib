/' timer() function '/

#include "../fb.bi"
#include "time.bi"
#include "sys/time.bi"

Extern "c"
Function fb_Timer FBCALL( ) as double

	dim tv as timeval
	dim result as double
	gettimeofday(@tv, NULL)
	result = tv.tv_sec * 1000000.0
	result += tv.tv_usec
	return result * 0.000001
End Function
End Extern
