/' print # function (formating is done at io_prn) '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_hFilePrintBufferEx( handle as FB_FILE ptr, buffer as any const ptr, _len as size_t ) as long
    fb_DevScrnInit_Write( )
	return fb_FilePutDataEx( handle, 0, buffer, _len, TRUE, TRUE, FALSE )
end function

/':::::'/
function fb_hFilePrintBuffer( fnum as long, buffer as ubyte const ptr ) as long
    return fb_hFilePrintBufferEx( FB_FILE_TO_HANDLE(fnum), buffer, strlen( buffer ) )
end function
end extern