/' mutex handling routines '/

#include "../fb.bi"
#include "unix_private_thread.bi"

Extern "c"
Function fb_MutexCreate FBCALL( void ) As FBMUTEX Ptr

	Dim mutex As FBMUTEX Ptr = New FBMUTEX
	If( mutex <> Null) Then
		pthread_mutex_init( @mutex->id, NULL )
	End if

	Return mutex
End Function

Sub fb_MutexDestroy FBCALL( ByVal mutex As FBMUTEX Ptr )

	If( mutex <> Null ) Then
		pthread_mutex_destroy( @mutex->id )
		Delete mutex
	End If
End Sub

Sub fb_MutexLock FBCALL( ByVal mutex As FBMUTEX Ptr )

	If( mutex <> Null ) Then
		pthread_mutex_lock( @mutex->id )
	End If
End Sub

Sub fb_MutexUnlock FBCALL( ByVal mutex As FBMUTEX Ptr )

	If( mutex <> Null ) Then
		pthread_mutex_unlock( @mutex->id )
	End If
End Sub
End Extern
