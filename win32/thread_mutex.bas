/' mutex handling routines '/

#include "../fb.bi"
#include "win32_private_thread.bi"

extern "C"
function fb_MutexCreate FBCALL ( ) as FBMUTEX ptr
	dim as FBMUTEX ptr mutex = New FBMUTEX
	if ( mutex <> NULL ) then
		mutex->id = CreateSemaphore( NULL, 1, 1, NULL )
	end if

	return mutex
end function

sub fb_MutexDestroy FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex <> NULL ) then
		CloseHandle( mutex->id )
		Delete mutex
	end if
end sub

sub fb_MutexLock FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex <> NULL ) then
		WaitForSingleObject( mutex->id, INFINITE )
	end if
end sub

sub fb_MutexUnlock FBCALL ( mutex as FBMUTEX ptr )
	if ( mutex <> NULL ) then
		ReleaseSemaphore( mutex->id, 1, NULL )
	end if
end sub
end extern