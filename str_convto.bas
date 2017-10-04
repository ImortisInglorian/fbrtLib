/' str$ routines for int, uint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_IntToStr FBCALL ( num as long ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, sizeof( long ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
		sprintf( dst->_data, "%d", num )

		fb_hStrSetLength( dst, strlen( dst->_data ) )
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

/':::::'/
function fb_UIntToStr FBCALL ( num as uinteger ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, sizeof( long ) * 3 )
	if ( dst <> NULL ) then
		/' convert '/
		sprintf( dst->_data, "%u", num )
		fb_hStrSetLength( dst, strlen( dst->_data ) )
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function
end extern