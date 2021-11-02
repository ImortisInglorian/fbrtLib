/' thread creation and destruction functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "unix_private_thread.bi"

'' We don't have clock_gettime in our headers
'' so we can't do this yet
'' Also requires pthread_timedjoin_np
#define PTHREAD_NO_TIMED_WAIT
#ifndef PTHREAD_NO_TIMED_WAIT
#include "crt/time.bi"
#endif

Type UnixHostThread Extends HostThread
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

Function host_ThreadCreate( byVal proc As FB_THREADPROC, ByVal param As Any Ptr, ByVal stack_size As ssize_t ) As HostThread Ptr

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
        Return New UnixHostThread( threadHandle )
End Function

Private Sub UnixHostThread.Detach( )
	pthread_detach( this.thread )
	this.freed = 1
End Sub

Private Function UnixHostThread.WaitForExit( ByVal timeToWait As Long ) As Long
	Assert( ( this.freed = 0 ) AndAlso ( "Somehow waiting for a detached thread!?" <> "" ) )
#ifndef PTHREAD_NO_TIMED_WAIT
	If (timeToWait <> -1 ) Then
		Dim timeout As timespec
		If( clock_gettime( CLOCK_REALTIME, @timeout ) = -1 )
			Return 0
		End If
		timeout.tv_sec += (timeToWait / 1000)
		timeout.tv_nsec += ((timeToWait Mod 1000) * 1000000)
		this.freed = (pthread_timedjoin_np( this.thread, Null, @timeout ) = 0)
		Function = this.freed
	Else
#else
	Assert( ( timeToWait = -1 ) AndAlso ( "PTHREAD_NO_TIMED_WAIT is defined, but a timeout was given to WaitForExit()" <> "" ) )
#endif
		pthread_join(this.thread, Null)
		this.freed = 1
#ifndef PTHREAD_NO_TIMED_WAIT
	End If
#endif
	Return this.freed
End Function

Private Constructor UnixHostThread( ByVal h As pthread_t )
	thread = h
	freed = 0
End Constructor

Private Destructor UnixHostThread( )
	If( freed = 0 ) Then
		pthread_close( this.thread )
	End If
End Destructor

