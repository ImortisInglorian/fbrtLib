/' wstring allocation function '/

#include "fb.bi"

extern "C"
function fb_WstrAlloc FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
	if ( chars <= 0 ) then
		return NULL
	end if

	return fb_wstr_AllocTemp( chars )
end function
end extern