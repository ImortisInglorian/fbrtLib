/' thread creation and destruction functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "crt/process.bi"

extern "Windows"
/' thread proxy to user's thread proc '/
#ifdef HOST_MINGW
private function threadproc ( param as any ptr ) as ulong
#else
private function threadproc ( param as LPVOID ) as DWORD
#endif
	dim as FBTHREADINFO ptr info = param
	dim as FBTHREAD ptr thread = info->thread
	dim as FBTHREADFLAGS flags
	
	_FB_TLSGETCTX( FBTHREAD )->self = thread

	/' call the user thread '/
	info->proc( info->param )
	free( info )

	/' free mem '/
	fb_TlsFreeCtxTb( )

	flags = fb_AtomicSetThreadFlags( @thread->flags, FBTHREAD_EXITED )

	/' This thread has been detached, we can free the thread structure '/
	if( flags and FBTHREAD_DETACHED ) then
		free( thread )
	end if

	return 1
end function
end extern

extern "C"

'' !!!TODO!!! see note in fb_thread.bi::_FB_TLSGETCTX(id)
'' #define fb_FBTHREADCTX_Destructor NULL
 
sub fb_FBTHREADCTX_Destructor( byval data_ as any ptr )
end sub

function fb_ThreadCreate FBCALL ( proc as FB_THREADPROC, param as any ptr, stack_size as ssize_t ) as FBTHREAD ptr
	dim as FBTHREAD ptr thread
	dim as FBTHREADINFO ptr info

	thread = cast(FBTHREAD ptr, malloc( sizeof( FBTHREAD ) ))
	if ( thread = NULL ) then
		return NULL
	end if

	info = cast(FBTHREADINFO ptr, malloc( sizeof( FBTHREADINFO ) ))
	if ( info = NULL ) then
		free( thread )
		return NULL
	end if

	info->proc = proc
	info->param = param
	info->thread = thread
	thread->flags = 0

#ifdef HOST_MINGW
	/' Note: _beginthreadex()'s last parameter cannot be NULL,
	   or else the function fails on Windows 9x '/
	dim as ulong thrdaddr
	thread->id = cast(HANDLE, _beginthreadex( NULL, stack_size, @threadproc, info, 0, @thrdaddr ))
#else
	dim as DWORD dwThreadId
	thread->id = CreateThread( NULL, stack_size, @threadproc, info, 0, @dwThreadId )
#endif

	if ( thread->id = NULL ) then
		free( thread )
		free( info )
		return NULL
	end if

	return thread
end function

sub fb_ThreadWait FBCALL ( thread as FBTHREAD ptr )
	/' A wait for the main thread or ourselves will never end
	   also, if we've been detached, we've nothing to wait on
	'/
	if( ( thread = NULL ) orelse _
		( ( thread->flags and ( FBTHREAD_MAIN or FBTHREAD_DETACHED ) ) <> 0 ) orelse _
		( thread = _FB_TLSGETCTX( FBTHREAD )->self ) ) then
		return
	end if

	WaitForSingleObject( thread->id, INFINITE )

    /' Never forget to close the threads handle ... otherwise we'll
     * have "zombie" threads in the system ... '/
    CloseHandle( thread->id )

	free( thread )
end sub
end extern