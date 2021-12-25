#include "fb.bi"

extern "C"
function fb_UCASE FBCALL ( src as FBSTRING ptr, dst as FBSTRING ptr ) as FBSTRING ptr
	return fb_StrUcase2( src, 0, dst )
end function
end extern
