/' open LPTx '/

#include "fb.bi"

extern "C"
private sub close_printer_handle( )
    if ( FB_HANDLE_PRINTER.hooks = NULL ) then
        exit sub
	end if
    FB_HANDLE_PRINTER.hooks->pfnClose( @FB_HANDLE_PRINTER )
end sub

#if defined( HOST_WIN32 )
dim shared as ubyte ptr pszPrinterDev = sadd("LPT:EMU=TTY")
#elseif defined( HOST_LINUX )
dim shared as ubyte ptr pszPrinterDev = sadd("LPT:")
#else
dim shared as ubyte const ptr pszPrinterDev = "LPT1:"
#endif

function fb_LPrintInit( ) as long
    if( FB_HANDLE_PRINTER.hooks = NULL) then
        dim as long res = fb_FileOpenVfsRawEx( @FB_HANDLE_PRINTER, _
											   pszPrinterDev, _
											   strlen(pszPrinterDev), _
											   FB_FILE_MODE_APPEND, _
											   FB_FILE_ACCESS_WRITE, _
											   FB_FILE_LOCK_READWRITE, _
											   0, _
											   FB_FILE_ENCOD_DEFAULT, _
											   @fb_DevLptOpen )
        if ( res = FB_RTERROR_OK ) then
            atexit(@close_printer_handle)
        end if
        return res
    end if
    return fb_ErrorSetNum( FB_RTERROR_OK )
end function

/':::::'/
function fb_FileOpenLpt FBCALL ( str_filename as FBSTRING ptr, mode as ulong, _
								 access_ as ulong, _lock as ulong, _
								 fnum as long, _len as long, _encoding as ubyte const ptr ) as long
    if ( FB_FILE_INDEX_VALID( fnum ) = 0 ) then
    	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

    return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
                             str_filename, _
                             mode, _
                             access_, _
                             _lock, _
                             _len, _
                             fb_hFileStrToEncoding( _encoding ), _
                             @fb_DevLptOpen )

end function
end extern