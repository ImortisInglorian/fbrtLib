#if defined(HOST_UNIX) or defined(HOST_WIN32)

#ifdef HOST_WIN32
	#include "windows.bi"
	type FB_DYLIB as HANDLE
#else
	type FB_DYLIB as any ptr
#endif

extern "C"
declare function fb_hDynLoad      ( libname as const ubyte ptr, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr ) as FB_DYLIB
declare function fb_hDynLoadAlso  ( _lib as FB_DYLIB, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr, count as ssize_t ) as long
declare sub 	 fb_hDynUnload    ( _lib as FB_DYLIB ptr )
end extern
#endif
