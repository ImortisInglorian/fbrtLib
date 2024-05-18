/' Solaris pthread.h does not define PTHREAD_STACK_MIN '/
#ifndef PTHREAD_STACK_MIN
	#define PTHREAD_STACK_MIN 8192
#endif

/' phtreads will crash freebsd when stack size is too small
// The default of 2 KiB is too small.as tested on freebsd-13.0-i386
// 8 KiB seems about alright (jeffm) 
// see https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=234775
'/
#ifdef HOST_FREEBSD
	#define FBTHREAD_STACK_MIN 8192
#else
	#define FBTHREAD_STACK_MIN PTHREAD_STACK_MIN
#endif

enum
	FB_TLSKEY_ERROR
	FB_TLSKEY_DIR
	FB_TLSKEY_INPUT
	FB_TLSKEY_PRINTUSG
	FB_TLSKEY_GFX
	FB_TLSKEY_FBTHREAD
	FB_TLSKEY_PROFILE
	FB_TLSKEYS
end enum

Type FBTlsDestroyer As Sub( ByVal data As Any Ptr )

Type FBTlsDataCell
    As Any Ptr slotData
    As FBTlsDestroyer destroyer
End Type

Type HostThread Extends Object

    Declare Abstract Sub Detach ( )
    Declare Abstract Function WaitForExit ( ByVal timeToWait As Long = -1 ) As Long
    Declare Virtual Destructor

End Type

Type _FBTHREAD
Private:
    As FBTlsDataCell tlsData(0 to FB_TLSKEYS - 1)
    As Ulong objFlags
    As FBMUTEX Ptr flagMutex
    As HostThread Ptr hostTid

Public:
    Declare Function GetData ( ByVal key As Ulong ) As Any Ptr
    Declare Sub SetData ( ByVal key As Ulong, ByVal slotData As Any Ptr, ByVal destroyer As FBTlsDestroyer )
    '' Returns flags prior to the setting of flags
    Declare Function SetFlags ( ByVal flags As Ulong ) As Ulong
    Declare Function GetFlags ( ) As Ulong

    Declare Function WaitForExit ( ByVal timeoutInMs As Long = -1 ) As Long
    Declare Function Detach () As Long
    Declare Sub SetHostThread ( ByVal tid As HostThread Ptr )

    Declare Constructor( ByVal initialFlags As Ulong )
    Declare Destructor ( )
End Type

Declare Sub fb_SetCurrentThread ( ByVal ptr As FBTHREAD Ptr )
Declare Function fb_GetCurrentThread( ) As FBTHREAD Ptr

Enum FBTHREADFLAGS
	FBTHREAD_MAIN = 1
	FBTHREAD_EXITED = 2
	FBTHREAD_DETACHED = 4
End enum

Type _FB_THREADPROC As FB_THREADPROC

Declare Function host_ThreadCreate ( ByVal proc as _FB_THREADPROC, ByVal param as Any Ptr, ByVal stackSize as ssize_t ) As HostThread Ptr

#ifdef ENABLE_MT
Declare sub fb_TlsInit( )
Declare sub fb_TlsExit( )
#endif

#ifndef NULL
#print "really? no NULL"
#endif
