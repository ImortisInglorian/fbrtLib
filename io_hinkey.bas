#include "fb.bi"

extern "C"
/' Builds the string to be returned by the console/gfx inkey() functions '/

function fb_hMakeInkeyStr( key as long, result as FBSTRING ptr ) as FBSTRING ptr
	if ( key > &hFF ) then
		/' 2-byte extended keycode '/
		fb_CHR( result, 2, (key and &hFF), (key shr 8) )
	else
		fb_CHR( result, 1, key )
	end if

	return result
end function
end extern