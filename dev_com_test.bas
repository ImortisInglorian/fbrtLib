/' COMx device '/

#include "fb.bi"

extern "C"
function fb_DevComTestProtocolEx ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t, pPort as size_t ptr ) as long
    dim as ubyte ptr ch
    dim as size_t i, port

    if ( pPort <> 0 ) then
        *pPort = 0
    end if

    if ( strncasecmp(filename, sadd("SER:"), 4) = 0 ) then
        if ( pPort ) then
            *pPort = 1
		end if
        return TRUE
    end if

    if ( filename_len < 4 ) then
        return FALSE
	end if
    
    if ( strncasecmp(filename, sadd("COM"), 3) <> 0 ) then
    	return strchr( filename, asc(":") ) <> NULL
	end if

    port = 0
    i = 3
    ch =  @filename[i]
    while( ch >= asc("0") and ch <= asc("9") )
        port = port * 10 + (*ch - asc("0"))
        ch = @filename[i + 1]
    wend

		/' removed to allow for open com "COM:"
    if( port==0 )
        return FALSE;
		'/
    if ( ch <> asc(":") ) then
        return FALSE
	end if

    if ( pPort <> 0 ) then
        *pPort = port
	end if

    return TRUE
end function

function fb_DevComTestProtocol ( handle as FB_FILE ptr, filename as ubyte const ptr, filename_len as size_t ) as long
    return fb_DevComTestProtocolEx( handle, filename, filename_len, NULL )
end function
end extern
