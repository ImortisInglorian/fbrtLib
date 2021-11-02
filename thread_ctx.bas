/' thread local context storage '/

#include "fb.bi"
#include "fb_private_thread.bi"
#include "fb_gfx_private.bi"

#if defined(ENABLE_MT) and defined(HOST_UNIX)
#include "crt/pthread.bi"
	#define FB_TLSENTRY           pthread_key_t
	#define FB_TLSALLOC(key)      pthread_key_create( @(key), NULL )
	#define FB_TLSFREE(key)       pthread_key_delete( (key) )
	#define FB_TLSSET(key,value)  pthread_setspecific( (key), cast(const any ptr, (value)) )
	#define FB_TLSGET(key)        pthread_getspecific( (key) )
#elseif defined(ENABLE_MT) and defined(HOST_DOS)
#include "crt/pthread.bi"
	#define FB_TLSENTRY           pthread_key_t
	#define FB_TLSALLOC(key)      pthread_key_create( @(key), NULL )
	#define FB_TLSFREE(key)       pthread_key_delete( (key) )
	#define FB_TLSSET(key,value)  pthread_setspecific( (key), cast(const any ptr, (value)) )
	#define FB_TLSGET(key)        pthread_getspecific( (key) )
#elseif defined(ENABLE_MT) and defined(HOST_WIN32)
#include "windows.bi"
	#define FB_TLSENTRY           DWORD
	#define FB_TLSALLOC(key)      key = TlsAlloc( )
	#define FB_TLSFREE(key)       TlsFree( (key) )
	#define FB_TLSSET(key,value)  TlsSetValue( (key), cast(LPVOID, (value)) )
	#define FB_TLSGET(key)        TlsGetValue( (key) )
#else
	#define FB_TLSENTRY           UInteger
	#define FB_TLSALLOC(key)      key = NULL
	#define FB_TLSFREE(key)       key = NULL
	#define FB_TLSSET(key,value)  key = cast(FB_TLSENTRY, value)
	#define FB_TLSGET(key)        key
#endif

dim shared as FB_TLSENTRY __fb_tls_ctxtb

extern "C"
/' This function is now only needed to support GfxLib '/
function fb_TlsGetCtx FBCALL ( index as long, _len as size_t, destructorFn as FBTlsDestroyer ) as any ptr
	dim curThread As FBThread Ptr = fb_GetCurrentThread( )
        dim ctx As Any Ptr = curThread->GetData( index )

	if ( ctx = NULL ) then
		ctx = CAllocate( _len )
                curThread->SetData( index, ctx, destructorFn )
	end if

	return ctx
end function
end extern

Sub fb_SetCurrentThread ( ByVal curThread As FBThread Ptr )
	Assert( fb_GetCurrentThread( ) = NULL )
	FB_TLSSET( __fb_tls_ctxtb, curThread )
End Sub

Function fb_GetCurrentThread FBCALL ( ) As FBThread Ptr
	Return cast( FBThread Ptr, FB_TLSGET( __fb_tls_ctxtb ) )
End Function

#ifdef ENABLE_MT
sub fb_TlsInit()
	/' allocate thread local storage keys '/
	FB_TLSALLOC( __fb_tls_ctxtb )
end sub

sub fb_TlsExit( )
	/' free thread local storage keys '/
	FB_TLSFREE( __fb_tls_ctxtb )
end sub
#endif
