/' get file length by filename '/

#include "fb.bi"

extern "C"
function fb_FileLenEx( filename as const ubyte ptr ) as fb_off_t
	dim as FILE ptr fp
	dim as fb_off_t _len
	
	fp = fopen( filename, "rb" )
	if ( fp <> NULL ) then
		if ( fseeko( fp, 0, SEEK_END ) = 0 ) then
			if ( (_len = ftello( fp )) <> -1 ) then
				fclose( fp )
				fb_ErrorSetNum( FB_RTERROR_OK )
				return _len
			end if
		end if

		fclose( fp )
	end if

	fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	return 0
end function

function fb_FileLen FBCALL ( filename as const ubyte ptr ) as longint
	return fb_FileLenEx( filename )
end function
end extern