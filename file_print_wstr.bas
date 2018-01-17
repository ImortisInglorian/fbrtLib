/' print # function (formating is done at io_prn) '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_hFilePrintBufferWstrEx( handle as FB_FILE ptr, buffer as FB_WCHAR const ptr, _len as size_t) as long
    fb_DevScrnInit_WriteWstr( )
	return fb_FilePutDataEx( handle, 0, buffer, _len, TRUE, TRUE, TRUE )
end function

/':::::'/
function fb_hFilePrintBufferWstr ( fnum as long, buffer as FB_WCHAR const ptr ) as long
    return fb_hFilePrintBufferWstrEx( FB_FILE_TO_HANDLE(fnum), buffer, fb_wstr_Len( buffer ) )
end function
end extern