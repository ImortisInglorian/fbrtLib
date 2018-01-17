#include "fb.bi"

extern "C"
/' Builds the string to be returned by the console/gfx inkey() functions '/

function fb_hMakeInkeyStr( key as long ) as FBSTRING ptr
	dim as FBSTRING ptr res

	if ( key > &hFF ) then
		/' 2-byte extended keycode '/
		res = fb_CHR( 2, (key and &hFF), (key shr 8) )
	else
		res = fb_CHR( 1, key )
	end if

	return res
end function
end extern