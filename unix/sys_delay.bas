#include "../fb.bi"
#include "sys/select.bi"

Extern "C"
Sub fb_Delay FBCALL( msecs as long )

	dim tv as timeval
	tv.tv_sec = msecs / 1000
	tv.tv_usec = (msecs Mod 1000) * 1000
	select(0, NULL, NULL, NULL, @tv)
End Sub
End Extern