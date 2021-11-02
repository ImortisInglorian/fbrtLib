#include "fb.bi"
#include "fb_private_thread.bi"

Type FBThreadParams

    userProc As FB_THREADPROC
    userData As Any Ptr
    syncLock As FBMUTEX Ptr
    newThread As FBThread Ptr

End Type

Private Sub UserThreadInit FBCALL ( ByVal arg As Any Ptr )
    Dim threadParamsPtr As FBThreadParams Ptr = arg
    Dim threadParams As FBThreadParams = *threadParamsPtr
    Delete threadParamsPtr

    fb_MutexLock( threadParams.syncLock )
    fb_MutexUnlock( threadParams.syncLock )
    fb_MutexDestroy( threadParams.syncLock )

    Dim currentThread As FBThread Ptr = threadParams.newThread
    fb_SetCurrentThread( currentThread )
    threadParams.userProc( threadParams.userData )
    Dim threadFlags As Ulong = currentThread->SetFlags( FBTHREAD_EXITED )
    if( threadFlags And FBTHREAD_DETACHED ) Then
        Delete currentThread
    End If
    
End Sub

Extern "C"
Function fb_ThreadCreate FBCALL ( proc as FB_THREADPROC, param as Any Ptr, stackSize as ssize_t ) As FBTHREAD Ptr

#if defined(HOST_DOS) AndAlso not defined(ENABLE_MT)
    Return Null
#else

    Dim newThread As FBTHREAD Ptr = New FBTHREAD( 0 )
    Dim syncLock As FBMUTEX Ptr = fb_MutexCreate( )
    Dim threadParams As FBThreadParams Ptr = New FBThreadParams
    threadParams->userProc = proc
    threadParams->userData = param
    threadParams->newThread = newThread
    threadParams->syncLock = syncLock

    '' This is to make the new thread wait until
    '' we've set the host thread details before it gets to the
    '' users code
    fb_MutexLock( syncLock )

    Dim hostThreadInfo As HostThread Ptr = host_ThreadCreate( @UserThreadInit, threadParams, stackSize )
    If hostThreadInfo = Null Then
        Delete newThread
        Delete threadParams
        fb_MutexDestroy( syncLock )
        Return Null
    End If
    newThread->SetHostThread ( hostThreadInfo )
    fb_MutexUnlock ( syncLock )

    Return newThread

#endif

End Function

End Extern