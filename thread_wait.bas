#include "fb.bi"
#include "fb_private_thread.bi"

extern "C"
Sub fb_ThreadWait FBCALL( ByVal thread As FBTHREAD Ptr )

#if defined(HOST_DOS) AndAlso not defined(ENABLE_MT)
	Exit Sub
#else

        Dim curThread As FBThread Ptr = fb_GetCurrentThread( )

	'' Can't wait for the current thread
	If( ( thread = NULL ) OrElse ( curThread = thread ) ) Then
		Exit Sub
	End If

	If ( thread->WaitForExit( -1 ) ) Then
		Delete thread
	End If
#endif

End Sub
End Extern