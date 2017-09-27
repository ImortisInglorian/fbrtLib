/' str$ routines for float and double
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"


/':::::'/
function fb_FloatToStr FBCALL ( num as single ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, 7 + 8 )
	if ( dst <> NULL ) then
		dim as size_t tmp_len

		/' convert '/
		sprintf( dst->_data, "%.7g", num )

		tmp_len = strlen( dst->_data )				/' fake len '/

		/' skip the dot at end if any '/
		if ( tmp_len > 0 ) then
			if ( dst->_data[tmp_len-1] = sadd(".") ) then
				dst->_data[tmp_len-1] = 0
				tmp_len -= 1
			end if
		end if
		
		fb_hStrSetLength( dst, tmp_len )
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

/':::::'/
function fb_DoubleToStr FBCALL ( num as double) as FBSTRING ptr
	dim as FBSTRING ptr dst

	/' alloc temp string '/
	dst = fb_hStrAllocTemp( NULL, 16 + 8 )
	if ( dst <> NULL ) then
		dim as size_t tmp_len

		/' convert '/
		sprintf( dst->_data, "%.16g", num )

		tmp_len = strlen( dst->_data )				/' fake len '/

		/' skip the dot at end if any '/
		if ( tmp_len > 0 ) then
			if ( dst->_data[tmp_len-1] = sadd(".") ) then
				dst->_data[tmp_len-1] = 0
				tmp_len -= 1
			end if
		end if
		
		fb_hStrSetLength( dst, tmp_len )
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function
