#if defined (HOST_UNIX)
	#include "crt/pthread.bi"
	type _FBMUTEX
		as pthread_mutex_t id
	end type
#elseif defined( HOST_DOS ) andalso defined( ENABLE_MT )
	#include "crt/pthread.bi"
	type _FBMUTEX
		as pthread_mutex_t id
	end type
#elseif defined( HOST_WIN32 )
	#include "windows.bi"
	type _FBMUTEX
		as HANDLE id
	end type
#endif

/' Thread handle returned by threadcreate(), so the caller is able to track the
   thread (freed by threadwait/threaddetach).

   At least on Win32 we probably don't really need this - it would be enough to
   just use the HANDLE directly instead of wrapping it in an dynamically
   allocated FBTHREAD structure. (we're already assuming that NULL is an invalid
   handle in the win32 fb_ThreadCreate(), so that'd be nothing new)

   With pthreads though, it's not clear whether we could store a pthread_t into
   a void*, because pthread_t doesn't have to be an long or pointer, and
   furthermore, zero may be a valid value for it. '/

enum FBTHREADFLAGS
	FBTHREAD_MAIN = 1
	FBTHREAD_EXITED = 2
	FBTHREAD_DETACHED = 4
end enum

type _FBTHREAD 
#if defined( HOST_DOS ) andalso defined( ENABLE_MT )
	as pthread_t id
#elseif defined( HOST_DOS ) andalso not defined( ENABLE_MT )
	as long id
	as any ptr opaque
#elseif defined (HOST_UNIX)
	as pthread_t id
#elseif defined (HOST_WIN32)
	as HANDLE id
#elseif defined (HOST_XBOX)
	as HANDLE id
#else
#error Unexpected target
#endif
	as /'volatile'/ FBTHREADFLAGS flags '' !!!TODO!!! need volatile option
end type

/' Info structure passed to our internal threadproc()s, so it can call the
   user's threadproc (freed at the end of our threadproc()s) '/
type FBTHREADINFO
	as FB_THREADPROC      proc
	as any ptr            param
	as FBTHREAD ptr       thread
end type

type FB_FBTHREADCTX
	as FBTHREAD	ptr self
end type

extern "C"
'' !!!TODO!!! see note in fb_thread.bi::_FB_TLSGETCTX(id)
'' #define fb_FBTHREADCTX_Destructor NULL
declare sub fb_FBTHREADCTX_Destructor( as any ptr )

declare sub      fb_AllocateMainFBThread ( )
declare function fb_AtomicSetThreadFlags ( byval flags as /'volatile'/ FBTHREADFLAGS ptr, byval newflag as FBTHREADFLAGS ) as FBTHREADFLAGS

#ifdef ENABLE_MT
declare sub      fb_CloseAtomicFBThreadFlagMutex ( )
#endif
end extern
