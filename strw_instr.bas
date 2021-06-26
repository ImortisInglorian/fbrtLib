/' instrw function '/

#include "fb.bi"

extern "C"
function fb_WstrInstr FBCALL ( start as ssize_t, src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr ) as ssize_t
	dim as ssize_t r
	dim as FB_WCHAR ptr p

	if ( (src = NULL) or (patt = NULL) ) then
		return 0
	end if

	if ( (start > 0) and (start <= fb_wstr_Len( src )) and (fb_wstr_Len( patt ) <> 0 )) then
		p = fb_wstr_Instr( @src[start-1], patt )
		if( p <> NULL ) then
			r = fb_wstr_CalcDiff( src, p ) + 1
		else
			r = 0
		end if
	else
		r = 0
	end if

	return r
end function
end extern