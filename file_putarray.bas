/' put # function for arrays '/

#include "fb.bi"

extern "C"
function fb_FilePutArray FBCALL ( fnum as long, _pos as long, src as FBARRAY ptr ) as long
	return fb_FilePutData( fnum, _pos, src->_ptr, src->size, TRUE, FALSE )
end function

function fb_FilePutArrayLarge FBCALL ( fnum as long, _pos as longint, src as FBARRAY ptr ) as long
	return fb_FilePutData( fnum, _pos, src->_ptr, src->size, TRUE, FALSE )
end function
end extern