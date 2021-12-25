/' str$ routines for float and double
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_FloatToStr FBCALL ( num as single, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	/' alloc temp string '/
	if ( fb_hStrAlloc( @dst, 7 + 8 ) <> NULL ) then
		dim as size_t tmp_len
		dim as ubyte ptr dst_data = dst.data

		/' convert '/
		sprintf( dst_data, "%.7g", num )

		tmp_len = strlen( dst_data ) /' fake len '/

		/' skip the dot at end if any '/
		if ( tmp_len > 0 ) then
			if ( dst_data[tmp_len-1] = asc(".") ) then
				dst_data[tmp_len-1] = 0
				tmp_len -= 1
			end if
		end if
		
		fb_hStrSetLength( @dst, tmp_len )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function

/':::::'/
function fb_DoubleToStr FBCALL ( num as double, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, 16 + 8 ) <> NULL ) then
		dim as size_t tmp_len
		dim as ubyte ptr dst_data = dst.data

		/' convert '/
		sprintf( dst_data, "%.16g", num )

		tmp_len = strlen( dst_data )				/' fake len '/

		/' skip the dot at end if any '/
		if ( tmp_len > 0 ) then
			if ( dst_data[tmp_len-1] = asc(".") ) then
				dst_data[tmp_len-1] = 0
				tmp_len -= 1
			end if
		end if
		
		fb_hStrSetLength( @dst, tmp_len )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern
