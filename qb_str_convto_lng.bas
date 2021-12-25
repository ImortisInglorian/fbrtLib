/' QB compatible str$ routines for longint, ulongint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_LongintToStrQB FBCALL ( num as longint, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string tmp_str

	if ( fb_hStrAlloc( @tmp_str, sizeof( longint ) * 3 ) <> NULL ) then
		dim as ubyte ptr str_data = tmp_str.data
		/' convert '/
#ifdef HOST_WIN32
		str_data[0] = asc(" ")
		_i64toa( num, str_data + Iif(num >= 0, 1, 0), 10 )
#else
		sprintf( str_data, "% lld", num )
#endif
		fb_hStrSetLength( @tmp_str, strlen( str_data ) )
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function

/':::::'/
function fb_ULongintToStrQB FBCALL ( num as ulongint, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string tmp_str

	if ( fb_hStrAlloc( @tmp_str, sizeof( ulongint ) * 3 ) <> NULL ) then
		dim as ubyte ptr str_data = tmp_str.data
		/' convert '/
#ifdef HOST_WIN32
		str_data[0] = asc(" ")
		_ui64toa( num, str_data + Iif(num >= 0, 1, 0), 10 )
#else
		sprintf( str_data, "% llu", num )
#endif
		fb_hStrSetLength( @tmp_str, strlen( str_data ) )
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function
end extern