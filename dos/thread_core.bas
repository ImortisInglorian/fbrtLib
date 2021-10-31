/' thread creation and destruction functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "dos_private_thread.bi"

#ifdef ENABLE_MT

Type DosHostThread Extends HostThread
Private:
    As pthread_t thread
    As Long freed

Public:
    Declare Sub Detach( ) Override
    Declare Function WaitForExit( ByVal timeToWait As Long ) As Long Override
    Declare Constructor( ByVal h As pthread_t )
    Declare Destructor( ) Override
End Type

Type ThreadInfo
    As FB_THREADPROC proc
    As Any Ptr param
End Type

/' thread proxy to user's thread proc '/
Private Function threadproc ( param As Any Ptr ) As Any Ptr
	dim info as ThreadInfo ptr = param
        dim localInfo As ThreadInfo = *info
        Delete info
	localInfo.proc( localInfo.param )

	return cast(Any Ptr, 1)
End Function

#endif '' ENABLE_MT

Function host_ThreadCreate( byVal proc As FB_THREADPROC, ByVal param As Any Ptr, ByVal stack_size As ssize_t ) As HostThread Ptr

#ifdef ENABLE_MT
	Dim tattr As pthread_attr_t
	If(pthread_attr_init(@tattr) <> 0) Then
		Return Null
	End If

	/' see fb_private_thread.h for defintion of FBTHREAD_STACK_MIN '/
	stack_size = IIf(stack_size >= FBTHREAD_STACK_MIN, stack_size, FBTHREAD_STACK_MIN)
	pthread_attr_setstacksize( @tattr, stack_size )

	Dim threadInfo As ThreadInfo Ptr = New ThreadInfo(proc, param)
	Dim threadHandle As pthread_t
	Dim createResult As Long = pthread_create( @threadHandle, @tattr, @threadproc, threadInfo )
	pthread_attr_destroy(@tattr)
	If( createResult <> 0 ) Then
		Delete threadInfo
		Return Null
	End If
        Return New DosHostThread( threadHandle )

#else
	return NULL
#endif

End Function

#ifdef ENABLE_MT
Private Sub DosHostThread.Detach( )
	pthread_detach( this.thread )
	this.freed = 1
End Sub

Private Function DosHostThread.WaitForExit( ByVal timeToWait As Long ) As Long
	Assert( ( this.freed = 0 ) AndAlso ( "Somehow waiting for a detached thread!?" <> "" ) )
	Assert( ( timeToWait = -1 ) AndAlso ( "Dos threads do not support timed waits" <> "" ) )

	pthread_join(this.thread, Null)
	this.freed = 1
	Return this.freed
End Function

Private Constructor DosHostThread( ByVal h As pthread_t )
	thread = h
	freed = 0
End Constructor

Private Destructor DosHostThread( )
	If( freed = 0 ) Then
		pthread_close( this.thread )
	End If
End Destructor

#endif '' ENABLE_MT

