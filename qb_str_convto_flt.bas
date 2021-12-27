/' QB compatible str$ routines for float and double
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"


/':::::'/
extern "C"
function fb_FloatToStrQB FBCALL ( num as single, result as FBSTRING ptr ) as FBSTRING ptr
	dim tmp_str as destructable_string

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @tmp_str, 7+8 ) <> NULL ) then
		dim as size_t tmp_len
		dim as ubyte ptr str_data = tmp_str.data

		/' convert '/
		sprintf( str_data, "% .7g", num )

		tmp_len = strlen( str_data ) /' fake len '/

		/' skip the dot at end if any '/
		if tmp_len > 0 then
			if str_data[tmp_len-1] = asc(".") then
				str_data[tmp_len-1] = asc(!"\000")
				tmp_len -= 1
			end if
		end if
		fb_hStrSetLength( @tmp_str, tmp_len )
	end if
	
	fb_StrSwapDesc( result, @tmp_str )
	return result
end function

/':::::'/
function fb_DoubleToStrQB FBCALL ( num as double, result as FBSTRING ptr ) as FBSTRING ptr
	dim tmp_str as destructable_string

	if ( fb_hStrAlloc( @tmp_str, 16+8 ) <> NULL ) then
		dim as size_t tmp_len
		dim as ubyte ptr str_data = tmp_str.data

		/' convert '/
		sprintf( str_data, "% .16g", num )

		tmp_len = strlen( str_data ) /' fake len '/

		/' skip the dot at end if any '/
		if tmp_len > 0 then
			if str_data[tmp_len-1] = asc(".") then
				str_data[tmp_len-1] = asc(!"\000")
				tmp_len -= 1
			end if
		end if
		fb_hStrSetLength( @tmp_str, tmp_len )
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function
end extern