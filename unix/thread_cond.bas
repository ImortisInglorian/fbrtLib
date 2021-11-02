/' condition variable functions '/

#include "../fb.bi"
#include "unix_private_thread.bi"

Extern "c"
Function fb_CondCreate FBCALL ( ) As FBCOND Ptr

	Dim cond As FBCOND ptr = New FBCOND
	If( cond <> Null ) then
		pthread_cond_init( @cond->id, NULL )
	End If

	Return cond
End Function


Sub fb_CondDestroy FBCALL ( ByVal cond As FBCOND Ptr )

	If( cond <> Null ) Then
		pthread_cond_destroy( @cond->id )
		Delete cond
	End If
End Sub

Sub fb_CondSignal FBCALL ( ByVal cond As FBCOND Ptr )

	If( cond <> Null) Then
		pthread_cond_signal( @cond->id )
	End If
End Sub

Sub fb_CondBroadcast FBCALL( ByVal cond As FBCOND Ptr )

	If( cond <> Null ) Then
		pthread_cond_broadcast( &cond->id )
	End If
End Sub

Sub fb_CondWait FBCALL( ByVal cond As FBCOND Ptr, ByVal mutex As FBMUTEX Ptr )

	If( ( cond <> Null ) AndAlso (mutex <> Null) ) {
		pthread_cond_wait( @cond->id, @mutex->id )
	End If
End Sub
End Extern
