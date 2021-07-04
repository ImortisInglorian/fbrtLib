/' trimw$ ANY function '/

#include "fb.bi"

extern "C"
function fb_WstrTrimAny FBCALL ( src as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
    dim as const FB_WCHAR ptr pachText = NULL
	dim as FB_WCHAR ptr dst
	dim as ssize_t _len

    if ( src = NULL ) then
        return NULL
    end if

	_len = 0
	scope
		dim as ssize_t len_pattern = fb_wstr_Len( pattern )
		pachText = src
		_len = fb_wstr_Len( src )
		if( len_pattern <> 0 ) then
			while ( _len <> 0 )
				if( wcschr( pattern, *pachText ) = NULL ) then
					exit while
				end if
				_len -= 1
				pachText += 1
			wend
			while ( _len <> 0 )
				_len -= 1
				if( wcschr( pattern, pachText[_len] ) = NULL ) then
					_len += 1
					exit while
				end if
			wend
		end if
	end scope

	if ( _len > 0 ) then
		/' alloc temp string '/
        dst = fb_wstr_AllocTemp( _len )
		if ( dst <> NULL ) then
			/' simple copy '/
			fb_wstr_Copy( dst, pachText, _len )
		else
			dst = NULL
		end if
	else
		dst = NULL
	end if

	return dst
end function
end extern