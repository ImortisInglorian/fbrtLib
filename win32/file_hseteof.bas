/' low-level truncate / set end of file '/

#include "../fb.bi"
#include "crt/io.bi"

/'
    including unistd.h will fail with TDM toolchain
	when NO_OLDNAMES is defined.  If we ever did
	want to use ftruncate() instead of SetEndOfFile()
	we would need to include unistd.h.  In the
	meantime, just include windows.h and use
	SetEndOfFile().  Since ftruncate(), in theory
	should just resolve to a system call anyway, we
	should be OK with this on all windows toolchains
	for now.
'/
#if 0
#include "unistd.bi"
#else
#include "windows.bi"
#endif

/'
    rely on mingw-w64 having FTRUNCATE_DEFINED defined
    to let us know that ftruncate64 is defined.

    Otherwise, just call the windows API SetEndOfFile

    Perhaps in an updated version of mingw(org) we can
    remove the conditional compilation here and use
    only ftruncate/ftruncate64.  Would be nice if mingw
    supports _FILE_OFFSET_BITS in a later version than
    our current setup
'/
extern "C"

function fb_hFileSetEofEx( f as FILE ptr ) as long

#if defined( FTRUNCATE_DEFINED )
	dim as fb_off_t pos_
	pos_ = ftello( f )
	if( ftruncate64( _fileno(f), pos_ ) <> 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if
#else
	if( SetEndOfFile( cast(HANDLE, _get_osfhandle( _fileno( f ) ) ) ) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_FILEIO )
	end if
#endif

	return fb_ErrorSetNum( FB_RTERROR_OK )
	
end function

end extern
