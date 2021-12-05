/' low-level lock and unlock functions '/

#include "../fb.bi"
#include "fcntl.bi"

Function do_lock ( f as FILE ptr, lock as Long, inipos as fb_off_t, size as fb_off_t) as Long

	dim lck as flock
	dim fd as long = fileno( f )
	dim err as long

	if ( lock <> 0 ) then
		if ( ( fcntl( fd, F_GETFL ) And O_RDONLY ) <> 0 ) Then
			lck.l_type = F_RDLCK
		else
			lck.l_type = F_WRLCK
		end if
	else
		lck.l_type = F_UNLCK
	end if
	lck.l_whence = SEEK_SET
	lck.l_start = inipos
	lck.l_len = size

	err = Iif( fcntl( fd, F_SETLKW, @lck ) <> 0, FB_RTERROR_FILEIO, FB_RTERROR_OK )
	return fb_ErrorSetNum( err )

End Function

Function fb_hFileLock( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) As Long

	return do_lock(f, TRUE, inipos, size)
End Function

Function fb_hFileUnlock( f as FILE ptr, inipos as fb_off_t, size as fb_off_t ) As Long

	return do_lock(f, FALSE, inipos, size)
End Function
