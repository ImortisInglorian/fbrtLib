/' thread creation and destruction functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "win32_private_thread.bi"

Type Win32HostThread Extends HostThread
Private:
    As HANDLE hThread
    As Ulong tid

Public:
    Declare Sub Detach( ) Override
    Declare Function WaitForExit( ByVal timeToWait As Long ) As Long Override
    Declare Constructor( ByVal h As HANDLE, ByVal id As Ulong )
    Declare Destructor( ) Override
End Type

Type ThreadInfo
    As FB_THREADPROC proc
    As Any Ptr param
End Type

extern "Windows"
private function threadproc ( ByVal param as any ptr ) as ulong
	Dim info as ThreadInfo ptr = param
        Dim localInfo As ThreadInfo = *info
        Delete info
	localInfo.proc( localInfo.param )

	return 1
end function
end extern

Function host_ThreadCreate ( ByVal proc as FB_THREADPROC, ByVal param as Any Ptr, ByVal stackSize as ssize_t ) As HostThread Ptr
	Dim threadInfo As ThreadInfo Ptr = New ThreadInfo(proc, param)
        Dim id As Ulong = 0
        Dim hThread As HANDLE = CreateThread(NULL, stackSize, @threadProc, threadInfo, 0, @id)
        if(hThread = NULL) Then
		Delete threadInfo
	        Return Null
        End If
        Return New Win32HostThread( hThread, id )
        
End Function

Sub Win32HostThread.Detach( )
	CloseHandle( this.hThread )
	this.hThread = Null
End Sub

Function Win32HostThread.WaitForExit( ByVal timeToWait As Long ) As Long
	Assert( ( this.hThread <> Null ) AndAlso ( "Somehow waiting for a detached thread!?" <> "" ) )
	Return ( WaitForSingleObject( this.hThread, IIf( timeToWait = -1, INFINITE, timeToWait ) ) = WAIT_OBJECT_0 )
End Function

Private Constructor Win32HostThread( ByVal h As HANDLE, ByVal id As Ulong )
	hThread = h
	tid = id
End Constructor

Destructor Win32HostThread( )
	If( this.hThread <> Null ) Then
		CloseHandle( this.hThread )
	End If
End Destructor
