/' timer() function '/

#include "../fb.bi"
#include "crt/time.bi"
#include "windows.bi"

#define TIMER_NONE    0
#define TIMER_NORMAL  1
#define TIMER_HIGHRES 2
dim shared as integer _timer = TIMER_NONE
dim shared as double frequency

function fb_Timer FBCALL ( ) as double
	dim as LARGE_INTEGER count

	if ( _timer = TIMER_NONE ) then
		if ( QueryPerformanceFrequency( @count ) ) then
			frequency = 1.0 / cast(double, count.QuadPart)
			_timer = TIMER_HIGHRES
		else
			_timer = TIMER_NORMAL
		end if
	end if

	if ( _timer = TIMER_NORMAL ) then
		return cast(double, GetTickCount( )) * 0.001
	else
		QueryPerformanceCounter( @count )
		return cast(double, count.QuadPart) * frequency
	end if
end function
