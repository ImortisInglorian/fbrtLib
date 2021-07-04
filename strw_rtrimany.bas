/' rtrimw$ ANY function '/

#include "fb.bi"

extern "C"
function fb_WstrRTrimAny FBCALL ( src as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
	dim pachText as const FB_WCHAR ptr
	dim dst as FB_WCHAR ptr
	dim _len as ssize_t

	if( src = NULL ) then
		return NULL
	end if

	_len = fb_wstr_Len( src )
	scope
		dim len_pattern as ssize_t = fb_wstr_Len( pattern )
		pachText = src
		if( len_pattern <> 0 ) then
			while ( _len <> 0 )
				_len -= 1
				if( wcschr( pattern, pachText[_len] ) = NULL ) then
					_len += 1
					exit while
				end if
			wend
		end if
	end scope

	if( _len > 0 ) then
		/' alloc temp string '/
		dst = fb_wstr_AllocTemp( _len )
		if( dst <> NULL ) then
			/' simple copy '/
			fb_wstr_Copy( dst, src, _len )
		else
			dst = NULL
		end if
	else
		dst = NULL
	end if
	return dst
end function
end extern