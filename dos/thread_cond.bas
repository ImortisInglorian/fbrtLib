/' condition variable functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "dos_private_thread.bi"

Extern "c"
Function fb_CondCreate FBCALL( ) As FBCOND Ptr

#ifdef ENABLE_MT
	Dim cond As FBCOND Ptr = New FBCOND

	if( cond <> Null ) Then
		pthread_cond_init( @cond->id, NULL )
	End If

	Return cond
#else
	Return NULL
#endif
        
End Function

Sub fb_CondDestroy FBCALL( ByVal cond As FBCOND Ptr )

#ifdef ENABLE_MT
	If( cond <> Null) Then
		pthread_cond_destroy( @cond->id )
		Delete cond
	End If
#endif
        
End Sub

Sub fb_CondSignal FBCALL ( ByVal cond As FBCOND Ptr )

#ifdef ENABLE_MT
	if( cond <> Null ) Then
		pthread_cond_signal( @cond->id )
	End If
#endif
        
End Sub

Sub fb_CondBroadcast FBCALL( ByVal cond As FBCOND Ptr )

#ifdef ENABLE_MT
	if( cond <> Null) Then
		pthread_cond_broadcast( @cond->id )
	End If
#endif
        
End Sub

Sub fb_CondWait FBCALL( ByVal cond As FBCOND Ptr, ByVal mutex As FBMUTEX Ptr )

#ifdef ENABLE_MT
	if( (cond <> Null ) AndAlso ( mutex <> Null ) ) Then
		pthread_cond_wait( @cond->id, @mutex->id )
	End If
#endif

End Sub
End Extern

