/' open and core file functions '/

#include "fb.bi"

extern "C"
function fb_FileOpenEx( handle as FB_FILE ptr, _str as FBSTRING ptr, mode as ulong, access_ as ulong, _lock as ulong, _len as long ) as long
	return fb_FileOpenVfsEx( handle, _str, mode, access_, _lock, _len, FB_FILE_ENCOD_DEFAULT, @fb_DevFileOpen )
end function

function fb_FileOpen FBCALL ( _str as FBSTRING ptr, mode as ulong, access_ as ulong, _lock as ulong, fnum as long, _len as long ) as long
	if ( FB_FILE_INDEX_VALID( fnum ) = 0 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
	return fb_FileOpenEx( FB_FILE_TO_HANDLE(fnum), _str, mode, access_, _lock, _len )
end function
end extern