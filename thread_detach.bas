#include "fb.bi"
#include "fb_private_thread.bi"

extern "C"
Sub fb_ThreadDetach FBCALL( ByVal thread As FBTHREAD Ptr )

#if defined(HOST_DOS) AndAlso not defined(ENABLE_MT)
	Exit Sub
#else

	If( thread = NULL ) Then
		Exit Sub
	End If

	If ( thread->Detach( ) ) Then
		Delete thread
	End If
#endif

End Sub
End Extern