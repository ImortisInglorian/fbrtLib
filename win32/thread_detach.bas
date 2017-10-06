#include "../fb.bi"
#include "../fb_private_thread.bi"

extern "C"
sub fb_ThreadDetach FBCALL ( thread as FBTHREAD ptr )
	if ( thread = NULL ) then
		exit sub
	end if

	CloseHandle( thread->id )

	free( thread )
end sub
end extern