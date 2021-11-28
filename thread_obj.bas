#include "fb.bi"
#include "fb_private_thread.bi"

Constructor _FBTHREAD( ByVal initialFlags As Ulong )
    objFlags = initialFlags
    flagMutex = MutexCreate( )
End Constructor

Destructor _FBTHREAD( )
    Dim cell As FBTlsDataCell Ptr = @this.tlsData(0)
    Dim cellsEnd As FBTlsDataCell Ptr = cell + (FB_TLSKEYS - 1)
    While cell <> cellsEnd
        If( cell->destroyer <> 0 ) Then
            cell->destroyer( cell->slotData )
        End If
        cell = cell + 1
    Wend
    MutexDestroy( flagMutex )
    Delete hostTid
End Destructor

Function _FBTHREAD.GetData ( ByVal key as Ulong ) As Any Ptr
    Assert( key <= UBound( this.tlsData ) ) '' alternate: (key < FB_TLSKEYS)
    Return this.tlsData( key ).slotData
End Function

Sub _FBTHREAD.SetData ( ByVal key As Ulong, ByVal slotData As Any Ptr, ByVal destroyer As FBTlsDestroyer )
    Assert( key <= UBound(this.tlsData) ) '' alternate: (key < FB_TLSKEYS)
    Dim cell As FBTlsDataCell Ptr = @this.tlsData(key)
    If( cell->destroyer <> 0 ) Then
        cell->destroyer( cell->slotData )
    End If
    cell->destroyer = destroyer
    cell->slotData = slotData
End Sub

Function _FBTHREAD.SetFlags ( ByVal newFlags As Ulong ) As Ulong
    Dim oldFlags As Ulong
    MutexLock( this.flagMutex )
        oldFlags = this.objFlags
        this.objFlags Or= newFlags
    MutexUnlock( this.flagMutex )
    Return oldFlags
End Function

Function _FBTHREAD.GetFlags ( ) As Ulong
    Dim oldFlags As Ulong
    MutexLock( this.flagMutex )
        oldFlags = this.objFlags
    MutexUnlock( this.flagMutex )
    Return oldFlags
End Function

Sub _FBTHREAD.SetHostThread ( ByVal thread As HostThread Ptr )
    hostTid = thread
End Sub

Function _FBTHREAD.WaitForExit ( ByVal timeoutInMs As Long ) As Long
    '' Can't wait for the main thread, or if detached
    '' Or wait for ourselves
    Assert( ( hostTid <> Null ) AndAlso ( "Host thread was Null!" <> "" ) )
    Dim curFlags As Ulong = this.GetFlags( )
    If( ( curFlags And ( FBTHREAD_MAIN Or FBTHREAD_DETACHED ) ) = 0 ) Then
        hostTid->WaitForExit( timeoutInMs )
        Function = 1
    Else
        Assert( ( ( curFlags And FBTHREAD_MAIN ) = 0 ) AndAlso ( "Trying to wait for main thread" <> "" ) )
    End If
    
End Function

Function _FBTHREAD.Detach () As Long
    '' Can't detach the main thread
    Assert( ( hostTid <> Null ) AndAlso ( "Host thread was Null!" <> "" ) )
    Dim curFlags As Ulong = this.GetFlags( )
    If( ( curFlags And FBTHREAD_MAIN ) = 0 ) Then
        Dim oldFlags As Ulong = this.SetFlags( FBTHREAD_DETACHED )
        hostTid->Detach()
        Function = ( ( oldFlags And FBTHREAD_EXITED ) <> 0 )
    Else
        Assert( "Trying to detach main thread" = "")
    End If
End Function

'' Can't have abstract destructors, so we need this
Destructor HostThread( )
End Destructor
