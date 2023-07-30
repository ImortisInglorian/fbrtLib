#ifdef fb_ThreadCall
	#undef fb_ThreadCall
#endif

type FB_THREADPROC as sub FBCALL( param as any ptr )

type FBTHREAD as _FBTHREAD

type FBMUTEX as _FBMUTEX

type FBCOND as _FBCOND

extern "C"
declare function fb_ThreadCreate 		FBCALL ( byval proc as FB_THREADPROC, byval param as any ptr, byval stack_size as ssize_t ) as FBTHREAD ptr
declare function fb_ThreadSelf          FBCALL ( ) as FBTHREAD ptr
declare sub 	 fb_ThreadWait 			FBCALL ( byval thread as FBTHREAD ptr )
declare sub 	 fb_ThreadDetach 		FBCALL ( byval thread as FBTHREAD ptr )

declare function fb_ThreadCall 			       ( byval proc as any ptr, byval abi as long, byval stack_size as ssize_t, byval num_args as long, ... ) as FBTHREAD ptr

declare function fb_MutexCreate 		FBCALL ( ) as FBMUTEX ptr
declare sub 	 fb_MutexDestroy 		FBCALL ( byval mutex as FBMUTEX ptr )
declare sub 	 fb_MutexLock 			FBCALL ( byval mutex as FBMUTEX ptr )
declare sub 	 fb_MutexUnlock 		FBCALL ( byval mutex as FBMUTEX ptr )

declare function fb_CondCreate 			FBCALL ( ) as FBCOND ptr
declare sub 	 fb_CondDestroy 		FBCALL ( byval cond as FBCOND ptr )
declare sub 	 fb_CondSignal 			FBCALL ( byval cond as FBCOND ptr )
declare sub 	 fb_CondBroadcast 		FBCALL ( byval cond as FBCOND ptr )
declare sub 	 fb_CondWait 			FBCALL ( byval cond as FBCOND ptr, mutex as FBMUTEX ptr )

end extern