/' fre() function '/

#include "../fb.bi"
#include "sys/sysinfo.bi"

Extern "c"
Function fb_GetMemAvail FBCALL( mode as long ) as size_t

	return get_avphys_pages() * sysconf(_SC_PAGE_SIZE)
End Function
End Extern
