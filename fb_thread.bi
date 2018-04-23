#ifdef fb_ThreadCall
	#undef fb_ThreadCall
#endif


type FB_THREADPROC as sub( param as any ptr )

type FBTHREAD as _FBTHREAD

type FBMUTEX as _FBMUTEX

type FBCOND as _FBCOND

extern "C"
declare function fb_ThreadCreate 		FBCALL ( proc as FB_THREADPROC, param as any ptr, stack_size as ssize_t ) as FBTHREAD ptr
declare sub 	 fb_ThreadWait 			FBCALL ( thread as FBTHREAD ptr )
declare sub 	 fb_ThreadDetach 		FBCALL ( thread as FBTHREAD ptr )

declare function fb_ThreadCall 			       ( proc as any ptr, abi as long, stack_size as ssize_t, num_args as long, ... ) as FBTHREAD ptr

declare function fb_MutexCreate 		FBCALL ( ) as FBMUTEX ptr
declare sub 	 fb_MutexDestroy 		FBCALL ( mutex as FBMUTEX ptr )
declare sub 	 fb_MutexLock 			FBCALL ( mutex as FBMUTEX ptr )
declare sub 	 fb_MutexUnlock 		FBCALL ( mutex as FBMUTEX ptr )

declare function fb_CondCreate 			FBCALL ( ) as FBCOND ptr
declare sub 	 fb_CondDestroy 		FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondSignal 			FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondBroadcast 		FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondWait 			FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * per-thread local storage context
 *************************************************************************************************'/

enum
	FB_TLSKEY_ERROR
	FB_TLSKEY_DIR
	FB_TLSKEY_INPUT
	FB_TLSKEY_PRINTUSG
	FB_TLSKEY_GFX
	FB_TLSKEYS
end enum

declare function fb_TlsGetCtx 			FBCALL ( index as long, _len as size_t ) as any ptr
declare sub 	  fb_TlsDelCtx 			FBCALL ( index as long )
declare sub 	  fb_TlsFreeCtxTb 		FBCALL ( )
#ifdef ENABLE_MT
declare sub 	  fb_TlsInit 				   ( )
declare sub 	  fb_TlsExit 			       ( )
#endif

#define _FB_TLSGETCTX(id) (cast(FB_##id##CTX ptr, fb_TlsGetCtx( FB_TLSKEY_##id, sizeof( FB_##id##CTX ) )))
end extern