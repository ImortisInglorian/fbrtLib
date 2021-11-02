/' mutex handling routines '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "dos_private_thread.bi"

Extern "C"
Function fb_MutexCreate FBCALL( ) As FBMUTEX Ptr

#ifdef ENABLE_MT
	dim mutex As FBMUTEX Ptr = New FBMUTEX
	if( mutex <> Null) Then
		pthread_mutex_init( @mutex->id, NULL )
	End If

	Return mutex
#else
	Return NULL
#endif

End Function

Sub fb_MutexDestroy FBCALL( ByVal mutex As FBMUTEX Ptr )

#ifdef ENABLE_MT
	If( mutex <> Null ) Then
		pthread_mutex_destroy( @mutex->id )
		Delete mutex
	End If
#endif

End Sub

Sub fb_MutexLock FBCALL( ByVal mutex As FBMUTEX Ptr )

#ifdef ENABLE_MT
	If( mutex <> null ) Then
		pthread_mutex_lock( @mutex->id )
	End If
#endif

End Sub

Sub fb_MutexUnlock FBCALL( ByVal mutex As FBMUTEX Ptr )

#ifdef ENABLE_MT
	If( mutex <> Null ) Then
		pthread_mutex_unlock( @mutex->id )
	End If
#endif

End Sub
End Extern

