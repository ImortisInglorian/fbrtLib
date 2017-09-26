/' rtrimw$ function '/

#include "fb.bi"

function fb_WstrRTrim FBCALL ( src as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim dst as FB_WCHAR ptr
	dim p as FB_WCHAR ptr
	dim chars as ssize_t

	if( src = NULL ) then
		return NULL
	end if
	
	chars = fb_wstr_Len( src )
	if( chars <= 0 ) then
		return NULL
	end if
	
	p = fb_wstr_SkipCharRev( src, chars, 32 )
	chars = fb_wstr_CalcDiff( src, p ) + 1
	if( chars <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( chars )
	if( dst <> NULL ) then
		/' simple copy '/
		fb_wstr_Copy( dst, src, chars )
	end if

	return dst
end function
