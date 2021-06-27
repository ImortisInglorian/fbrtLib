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

#define FB_TLS_DATA_TO_HEADER( data ) ( ( cast( FB_TLS_CTX_HEADER ptr, data ) - 1 ) )
#define FB_TLS_HEADER_TO_DATA( header ) ( cast( any ptr, header + 1 ) )

extern "C"
/' Retrieve or create new TLS context for given key '/
function fb_TlsGetCtx FBCALL ( index as long, _len as size_t, destructorFn as FB_TLS_DESTRUCTOR ) as any ptr
	dim as any ptr ctx = cast(any ptr, FB_TLSGET( __fb_tls_ctxtb(index) ))

	if ( ctx = NULL ) then
		dim as FB_TLS_CTX_HEADER ptr ctxheader = cast( FB_TLS_CTX_HEADER ptr, calloc( 1, _len + sizeof(FB_TLS_CTX_HEADER) ) )
		if( ctxHeader <> NULL ) then
			ctxHeader->destructor_ = destructorFn
			ctx = FB_TLS_HEADER_TO_DATA( ctxHeader )
			FB_TLSSET( __fb_tls_ctxtb(index), ctx )
		end if
	end if

	return ctx
end function

sub fb_TlsDelCtx FBCALL( index as long )
	dim as any ptr ctx = cast(any ptr, FB_TLSGET( __fb_tls_ctxtb(index) ))

	/' free mem block if any '/
	if ( ctx <> NULL ) then
		dim as FB_TLS_CTX_HEADER ptr ctxheader = FB_TLS_DATA_TO_HEADER( ctx )
		if( ctxHeader->destructor_ ) then
			ctxHeader->destructor_( ctx )
		end if
		free( ctxHeader )
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
	fb_CloseAtomicFBThreadFlagMutex( )
end sub
#endif
end extern