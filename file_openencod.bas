/' UTF-encoded file open function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileOpenEncod FBCALL ( _str as FBSTRING ptr, mode as ulong, access_ as ulong, _lock as ulong, fnum as long, _len as long, _encoding as ubyte const ptr ) as long
    if ( FB_FILE_INDEX_VALID( fnum ) = 0 ) then
    	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	dim as FB_FILE_ENCOD encod = fb_hFileStrToEncoding( _encoding )

	return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _str, mode, _
							 access_, _lock, _len, encod, _
							 iif(encod = FB_FILE_ENCOD_ASCII, _
							  @fb_DevFileOpen, _
							  @fb_DevFileOpenEncod) )
end function
end extern