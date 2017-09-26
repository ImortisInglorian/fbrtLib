/' rtrimw$ ANY function '/

#include "fb.bi"

function fb_WstrRTrimAny FBCALL ( src as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
	dim pachText as FB_WCHAR ptr
	dim dst as FB_WCHAR ptr
	dim _len as ssize_t

	if( src = NULL ) then
		return NULL
	end if

	_len = fb_wstr_Len( src )
	dim len_pattern as ssize_t = fb_wstr_Len( pattern )
	pachText = src
	while ( _len <> 0 )
		dim i as ssize_t
		_len -= 1
		for i = 0 to len_pattern
			if( wcschr( pattern, pachText[_len] ) <> NULL ) then
				exit for
			end if
		next
		if( i = len_pattern ) then
			_len += 1
			exit while
		end if
	wend

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