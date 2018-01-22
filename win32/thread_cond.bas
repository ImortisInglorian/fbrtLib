/''
 * Windows condition variables handling routines,
 * based on paper by Douglas C. Schmidt and Irfan Pyarali.
 *
 * The code can choose between two implementations at runtime:
 * one for Windows 9x, one for Windows NT.
 '/

#include "../fb.bi"
#include "../fb_private_thread.bi"

#define _SIGNAL		0
#define _BROADCAST	1

type w9x_t
	as HANDLE event(0 to 1)
end type

type nt_t
	as HANDLE sema /' semaphore for waiters '/
	as HANDLE waiters_done /' event '/
	as Boolean was_broadcast
end type

Type _FBCOND
	/' data common to both implementations '/
	as long waiters_count
	as CRITICAL_SECTION waiters_count_lock
	union
		as w9x_t w9x
		as nt_t nt
	end union
end type

type FBCONDOPS
	create as 		sub ( cond as FBCOND ptr )
	destroy as 		sub ( cond as FBCOND ptr )
	signal as 		sub ( cond as FBCOND ptr )
	broadcast as 	sub ( cond as FBCOND ptr )
	wait as 		sub ( cond as FBCOND ptr, mutex as FBMUTEX ptr )
end type

extern "C"
/' SignalObjectAndWait version '/
declare sub 	 fb_CondCreate_nt    FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondDestroy_nt   FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondSignal_nt    FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondBroadcast_nt FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondWait_nt      FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )

/' non-SignalObjectAndWait version '/
declare sub 	 fb_CondCreate_9x    FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondDestroy_9x   FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondSignal_9x    FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondBroadcast_9x FBCALL ( cond as FBCOND ptr )
declare sub 	 fb_CondWait_9x      FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )

type SIGNALOBJECTANDWAIT as function (as HANDLE, as HANDLE, as DWORD, as BOOL ) as DWORD

dim shared as SIGNALOBJECTANDWAIT pSignalObjectAndWait = NULL
dim shared as long __inited = FALSE
dim shared as FBCONDOPS __condops

sub fb_CondInit( )
	/' If two threads get here at the same time, make sure only one of
	   them does the initialization while the other one waits. '/
	FB_MT_LOCK()

	if ( __inited <> NULL ) then
		FB_MT_UNLOCK()
		exit sub
	end if

	/' win95: pSignalObjectAndWait==NULL
	   win98: pSignalObjectAndWait() returns ERROR_INVALID_FUNCTION
	   winnt: pSignalObjectAndWait() returns WAIT_FAILED '/

	pSignalObjectAndWait = cast(SIGNALOBJECTANDWAIT, GetProcAddress( GetModuleHandle( "KERNEL32" ), "SignalObjectAndWait" ))
	if ( (pSignalObjectAndWait <> NULL) and (pSignalObjectAndWait(NULL, NULL, 0, 0) = WAIT_FAILED) ) then
		__condops.create    = @fb_CondCreate_nt
		__condops.destroy   = @fb_CondDestroy_nt
		__condops.signal    = @fb_CondSignal_nt
		__condops.broadcast = @fb_CondBroadcast_nt
		__condops.wait      = @fb_CondWait_nt
	else
		__condops.create    = @fb_CondCreate_9x
		__condops.destroy   = @fb_CondDestroy_9x
		__condops.signal    = @fb_CondSignal_9x
		__condops.broadcast = @fb_CondBroadcast_9x
		__condops.wait      = @fb_CondWait_9x
	end if

	__inited = TRUE

	FB_MT_UNLOCK()
end sub

function fb_CondCreate FBCALL ( ) as FBCOND ptr
	dim as FBCOND ptr cond

	fb_CondInit( )

	cond = malloc( sizeof( FBCOND ) )
	if ( not(cond) ) then
		return NULL
	end if
	
	cond->waiters_count = 0
	InitializeCriticalSection( @cond->waiters_count_lock )
	__condops.create( cond )

	return cond
end function

sub fb_CondDestroy FBCALL ( cond as FBCOND ptr )
	if ( cond = NULL ) then
		exit sub
	end if
	DeleteCriticalSection( @cond->waiters_count_lock )
	__condops.destroy( cond )
	free( cond )
end sub

sub fb_CondSignal FBCALL ( cond as FBCOND ptr )
	dim as long has_waiters

	if ( cond = NULL ) then
		return
	end if
	
	EnterCriticalSection( @cond->waiters_count_lock )
	has_waiters = cond->waiters_count > 0
	LeaveCriticalSection( @cond->waiters_count_lock )

	if ( has_waiters <> NULL ) then
		__condops.signal( cond )
	end if
end sub

sub fb_CondBroadcast FBCALL ( cond as FBCOND ptr )
	if ( cond <> NULL ) then
		__condops.broadcast( cond )
	end if
end sub

sub fb_CondWait FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )
	if ( cond <> NULL and mutex <> NULL ) then
		__condops.wait( cond, mutex )
	end if
end sub

/' SignalObjectAndWait version '/

sub fb_CondCreate_nt FBCALL ( cond as FBCOND ptr )
	cond->nt.was_broadcast = FALSE
	cond->nt.sema = CreateSemaphore( NULL, 0, &h7fffffff, NULL )
	cond->nt.waiters_done = CreateEvent( NULL, FALSE, FALSE, NULL )
end sub

sub fb_CondDestroy_nt FBCALL ( cond as FBCOND ptr )
	CloseHandle( cond->nt.sema )
	CloseHandle( cond->nt.waiters_done )
end sub

sub fb_CondSignal_nt FBCALL ( cond as FBCOND ptr )
	ReleaseSemaphore( cond->nt.sema, 1, 0 )
end sub

sub fb_CondBroadcast_nt FBCALL ( cond as FBCOND ptr )
	EnterCriticalSection( @cond->waiters_count_lock )

	if ( cond->waiters_count > 0 ) then
		cond->nt.was_broadcast = TRUE

		ReleaseSemaphore( cond->nt.sema, cond->waiters_count, 0 )
		LeaveCriticalSection( @cond->waiters_count_lock )

		WaitForSingleObject( cond->nt.waiters_done, INFINITE )
		cond->nt.was_broadcast = FALSE
	else
		LeaveCriticalSection( @cond->waiters_count_lock )
	end if
end sub

sub fb_CondWait_nt FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )
	dim as long last_waiter

	EnterCriticalSection( @cond->waiters_count_lock )
	cond->waiters_count += 1
	LeaveCriticalSection( @cond->waiters_count_lock )

	/' unlock mutex and wait for waiters semaphore '/
	pSignalObjectAndWait( mutex->id, cond->nt.sema, INFINITE, FALSE )

	EnterCriticalSection( @cond->waiters_count_lock )
	cond->waiters_count -= 1
	last_waiter = cond->nt.was_broadcast and (cond->waiters_count = 0)
	LeaveCriticalSection( @cond->waiters_count_lock )

	/' relock mutex '/
	if ( last_waiter <> NULL ) then
		pSignalObjectAndWait( cond->nt.waiters_done, mutex->id, INFINITE, FALSE )
	else
		WaitForSingleObject( mutex->id, INFINITE )
	end if
end sub

/' non-SignalObjectAndWait version '/

sub fb_CondCreate_9x FBCALL ( cond as FBCOND ptr )
	cond->w9x.event(_SIGNAL)    = CreateEvent( NULL, FALSE, FALSE, NULL )
	cond->w9x.event(_BROADCAST) = CreateEvent( NULL, TRUE, FALSE, NULL )
end sub

sub fb_CondDestroy_9x FBCALL ( cond as FBCOND ptr )
	CloseHandle( cond->w9x.event(_SIGNAL) )
	CloseHandle( cond->w9x.event(_BROADCAST) )
end sub

sub fb_CondSignal_9x FBCALL( cond as FBCOND ptr )
	SetEvent( cond->w9x.event(_SIGNAL) )
end sub

sub fb_CondBroadcast_9x FBCALL ( cond as FBCOND ptr )
	dim as long has_waiters

	EnterCriticalSection( @cond->waiters_count_lock )
	has_waiters = (cond->waiters_count > 0)
	LeaveCriticalSection( @cond->waiters_count_lock )

	if ( has_waiters <> NULL ) then
		SetEvent( cond->w9x.event(_BROADCAST) )
	end if
end sub

sub fb_CondWait_9x FBCALL ( cond as FBCOND ptr, mutex as FBMUTEX ptr )
	dim as long result, last_waiter

	EnterCriticalSection( @cond->waiters_count_lock )
	cond->waiters_count += 1
	LeaveCriticalSection( @cond->waiters_count_lock )

	/' unlock mutex - WARNING: this is not atomic with the wait '/
	ReleaseSemaphore( mutex->id, 1, NULL )

	result = WaitForMultipleObjects( 2, @cond->w9x.event(0), FALSE, INFINITE )

	EnterCriticalSection( @cond->waiters_count_lock )
	cond->waiters_count -= 1
	last_waiter = (result = WAIT_OBJECT_0 + _BROADCAST) and (cond->waiters_count = 0)
	LeaveCriticalSection( @cond->waiters_count_lock )

	if ( last_waiter <> NULL ) then
		ResetEvent( cond->w9x.event(_BROADCAST) )
	end if

	/' relock mutex '/
	WaitForSingleObject( mutex->id, INFINITE )
end sub
end extern
