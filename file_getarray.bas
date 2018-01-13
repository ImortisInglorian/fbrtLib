/' get # function for arrays '/

#include "fb.bi"

extern "C"
function fb_FileGetArray FBCALL ( fnum as long, _pos as long, dst as FBARRAY ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _pos, dst->_ptr, dst->size, NULL, TRUE, FALSE )
end function

function fb_FileGetArrayLarge FBCALL ( fnum as long, _pos as longint, dst as FBARRAY ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _pos, dst->_ptr, dst->size, NULL, TRUE, FALSE )
end function

function fb_FileGetArrayIOB FBCALL ( fnum as long, _pos as long, dst as FBARRAY ptr, bytesread as size_t ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), pos, dst->_ptr, dst->size, bytesread, TRUE, FALSE )
end function

function fb_FileGetArrayLargeIOB FBCALL ( fnum as long, _pos as longint, dst as FBARRAY ptr, bytesread as size_t ptr ) as long
	return fb_FileGetDataEx( FB_FILE_TO_HANDLE(fnum), _pos, dst->_ptr, dst->size, bytesread, TRUE, FALSE )
end function
end extern