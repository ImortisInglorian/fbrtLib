/' thread local context storage '/

#include "fb.bi"
#include "fb_private_thread.bi"
#include "fb_gfx_private.bi"

#if defined(ENABLE_MT) and defined(HOST_UNIX)
	#define FB_TLSENTRY           pthread_key_t
	#define FB_TLSALLOC(key)      pthread_key_create( @(key), NULL )
	#define FB_TLSFREE(key)       pthread_key_delete( (key) )
	#define FB_TLSSET(key,value)  pthread_setspecific( (key), cast(any const ptr, (value)) )
	#define FB_TLSGET(key)        pthread_getspecific( (key) )
#elseif defined(ENABLE_MT) and defined(HOST_DOS)
	#define FB_TLSENTRY           pthread_key_t
	#define FB_TLSALLOC(key)      pthread_key_create( @(key), NULL )
	#define FB_TLSFREE(key)       pthread_key_delete( (key) )
	#define FB_TLSSET(key,value)  pthread_setspecific( (key), cast(any const ptr, (value)) )
	#define FB_TLSGET(key)        pthread_getspecific( (key) )
#elseif defined(ENABLE_MT) and defined(HOST_WIN32)
	#define FB_TLSENTRY           DWORD
	#define FB_TLSALLOC(key)      key = TlsAlloc( )
	#define FB_TLSFREE(key)       TlsFree( (key) )
	#define FB_TLSSET(key,value)  TlsSetValue( (key), cast(LPVOID, (value)) )
	#define FB_TLSGET(key)        TlsGetValue( (key) )
#else
	#define FB_TLSENTRY           uintptr_t
	#define FB_TLSALLOC(key)      key = NULL
	#define FB_TLSFREE(key)       key = NULL
	#define FB_TLSSET(key,value)  key = cast(FB_TLSENTRY, value)
	#define FB_TLSGET(key)        key
#endif

dim shared as FB_TLSENTRY __fb_tls_ctxtb(0 to FB_TLSKEYS - 1)

extern "C"
/' Retrieve or create new TLS context for given key '/
function fb_TlsGetCtx FBCALL ( index as long, _len as size_t ) as any ptr
	dim as any ptr ctx = cast(any ptr, FB_TLSGET( __fb_tls_ctxtb(index) ))

	if ( ctx = NULL ) then
		ctx = cast(any ptr, calloc( 1, _len ))
		FB_TLSSET( __fb_tls_ctxtb(index), ctx )
	end if

	return ctx
end function

sub fb_TlsDelCtx FBCALL( index as long )
	dim as any ptr ctx = cast(any ptr, FB_TLSGET( __fb_tls_ctxtb(index) ))

	/' free mem block if any '/
	if ( ctx <> NULL ) then
		if ( index = FB_TLSKEY_GFX ) then
			/' gfxlib2's TLS context is a special case: it stores
			   some malloc'ed data that stays alive forever, so it
			   so it requires extra clean-up when the thread exits.
			   see also gfxlib2's fb_hGetContext() '/
			free(cast(FB_GFXCTX ptr,ctx)->line )
		end if
		free( ctx )
		FB_TLSSET( __fb_tls_ctxtb(index), NULL )
	end if
end sub

sub fb_TlsFreeCtxTb FBCALL ( )
	/' free all thread local storage ctx's '/
	dim as long i
	for i = 0 to FB_TLSKEYS - 1
		fb_TlsDelCtx( i )
	next
end sub

#ifdef ENABLE_MT
sub fb_TlsInit()
	/' allocate thread local storage keys '/
	dim as long i
	for i = 0 to FB_TLSKEYS - 1
		FB_TLSALLOC( __fb_tls_ctxtb(i) )
	next
end sub

sub fb_TlsExit( )
	/' free thread local storage keys '/
	dim as long i
	for i = 0 to FB_TLSKEYS - 1
		FB_TLSFREE( __fb_tls_ctxtb(i) )
	next
end sub
#endif
end extern