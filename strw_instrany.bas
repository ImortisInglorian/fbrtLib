/' instranyw function '/

#include "fb.bi"

extern "C"
function fb_WstrInstrAny FBCALL ( start as ssize_t, src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr ) as ssize_t
	dim as ssize_t r = 0

	if ( (src <> NULL) and (patt <> NULL) ) then
		dim as ssize_t size_src = fb_wstr_Len( src )

		if ( (start > 0) and (start <= size_src) ) then
			r = fb_wstr_InstrAny( @src[start-1], patt ) + start

			if ( r > size_src ) then
				r = 0
			end if
		end if
	end if

	return r
end function
end extern