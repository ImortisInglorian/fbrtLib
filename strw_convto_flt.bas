/' strw$ routines for float and double '/

#include "fb.bi"

extern "C"
function fb_FloatToWstr FBCALL ( num as single ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, d
	dim as ssize_t _len

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( 7+8 )
	if ( dst <> NULL ) then
		/' convert '/
        FB_WSTR_FROM_FLOAT( dst, num )

		/' skip the dot at end if any '/
		_len = fb_wstr_Len( dst )
		if ( _len > 0 ) then
			d = @dst[_len-1]
			if ( *d = 46 ) then
				*d = 0
			end if
        end if
    end if

	return dst
end function

function fb_DoubleToWstr FBCALL ( num as double ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, d
	dim as ssize_t _len

	/' alloc temp string '/
    dst = fb_wstr_AllocTemp( 16+8 )
	if ( dst <> NULL ) then
        /' convert '/
        FB_WSTR_FROM_DOUBLE( dst, num )

		/' skip the dot at end if any '/
		_len = fb_wstr_Len( dst )
		if ( _len > 0 ) then
			d = @dst[_len-1]
			if( *d = 46 ) then
				*d = 0
			end if
        end if
	end if

	return dst
end function
end extern