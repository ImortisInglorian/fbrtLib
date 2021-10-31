#include "fb.bi"
#include "fb_private_thread.bi"

Extern "c"
Function fb_ThreadSelf FBCALL ( ) As FBTHREAD Ptr
	Return fb_GetCurrentThread( )
End Function
End Extern
