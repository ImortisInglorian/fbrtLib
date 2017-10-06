/' thread creation and destruction functions '/

#include "../fb.bi"
#include "../fb_private_thread.bi"
#include "crt/process.bi"

extern "C"
/' thread proxy to user's thread proc '/
#ifdef HOST_MINGW
function threadproc WINAPI ( param as any ptr ) as ulong
#else
function threadproc stdcall ( param as LPVOID ) as DWORD
#endif
	dim as FBTHREADINFO ptr info = param

	/' call the user thread '/
	info->proc( info->param )
	free( info )

	/' free mem '/
	fb_TlsFreeCtxTb( )

	return 1
end function

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

#ifdef HOST_MINGW
	/' Note: _beginthreadex()'s last parameter cannot be NULL,
	   or else the function fails on Windows 9x '/
	dim as ulong thrdaddr
	thread->id = cast(HANDLE, _beginthreadex( NULL, stack_size, threadproc, info, 0, @thrdaddr ))
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
	if ( thread = NULL ) then
		return
	end if

	WaitForSingleObject( thread->id, INFINITE )

    /' Never forget to close the threads handle ... otherwise we'll
     * have "zombie" threads in the system ... '/
    CloseHandle( thread->id )

	free( thread )
end sub
end extern