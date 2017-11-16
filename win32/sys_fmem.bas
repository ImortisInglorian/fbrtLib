/' fre() function '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_GetMemAvail FBCALL ( mode as long ) as size_t
	dim as MEMORYSTATUS ms
	ms.dwLength = sizeof( MEMORYSTATUS )
	GlobalMemoryStatus( @ms )
	return ms.dwAvailPhys
end function
end extern