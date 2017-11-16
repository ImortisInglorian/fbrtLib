/' console line input function '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleReadStr( buffer as ubyte ptr, _len as size_t ) as ubyte ptr
	dim as ubyte ptr res

	fb_hRestoreConsoleWindow( )
	FB_CON_CORRECT_POSITION()
	fb_hConsolePutBackEvents( )

	res = fgets( buffer, _len, stdin )

	fb_hUpdateConsoleWindow( )

	return res
end function
end extern