/' fre() function '/

#include "../fb.bi"
#include "crt/unistd.bi"

extern "C"
function fb_GetMemAvail FBCALL ( mode as long ) as size_t
   return sysconf(_SC_AVPHYS_PAGES) * sysconf(_SC_PAGE_SIZE)
end function
end extern
