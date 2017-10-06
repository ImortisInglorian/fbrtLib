/' mutex handling routines '/

#include "../fb.bi"
#include "../fb_private_thread.bi"

extern "C"
function fb_MutexCreate FBCALL ( ) as FBMUTEX ptr
	dim as FBMUTEX ptr mutex = cast(FBMUTEX ptr,malloc( sizeof( FBMUTEX ) ))
	if ( not(mutex) ) then
		return NULL
	end if

	mutex->id = CreateSemaphore( NULL, 1, 1, NULL )

	return mutex
end function

sub fb_MutexDestroy FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex ) then
		CloseHandle( mutex->id )
		free( cast(any ptr,mutex) )
	end if
end sub

sub fb_MutexLock FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex ) then
		WaitForSingleObject( mutex->id, INFINITE )
	end if
end sub

sub fb_MutexUnlock FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex ) then
		ReleaseSemaphore( mutex->id, 1, NULL )
	end if
end sub
end extern