#if defined (HOST_UNIX)
	#include "crt/pthread.bi"
	type _FBMUTEX
		as pthread_mutex_t
	end type
#elseif defined (HOST_WIN32)
	#include "windows.bi"
	type _FBMUTEX
		as HANDLE id
	end type
#endif

/' Info structure passed to our internal threadproc()s, so it can call the
   user's threadproc (freed at the end of our threadproc()s) '/
type FBTHREADINFO
	as FB_THREADPROC proc
	as any ptr       param
end type

/' Thread handle returned by threadcreate(), so the caller is able to track the
   thread (freed by threadwait/threaddetach).

   At least on Win32 we probably don't really need this - it would be enough to
   just use the HANDLE directly instead of wrapping it in an dynamically
   allocated FBTHREAD structure. (we're already assuming that NULL is an invalid
   handle in the win32 fb_ThreadCreate(), so that'd be nothing new)

   With pthreads though, it's not clear whether we could store a pthread_t into
   a void*, because pthread_t doesn't have to be an long or pointer, and
   furthermore, zero may be a valid value for it. '/
type _FBTHREAD 
#if defined (HOST_DOS)
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
end type
