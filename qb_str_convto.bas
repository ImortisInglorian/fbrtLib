/' QB compatible str$ routines for int, uint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_IntToStrQB FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim tmp_str as destructable_string

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @tmp_str, sizeof( long ) * 3 ) <> NULL ) then
		/' convert '/
		sprintf( tmp_str.data, "% d", num )
		fb_hStrSetLength( @tmp_str, strlen( tmp_str.data ) )
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function

/':::::'/
function fb_UIntToStrQB FBCALL ( num as ulong, result as FBSTRING ptr ) as FBSTRING ptr
	dim tmp_str as destructable_string

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @tmp_str, sizeof( ulong ) * 3 ) <> NULL ) then
		/' convert '/
		sprintf( tmp_str.data, " %u", num )
		fb_hStrSetLength( @tmp_str, strlen( tmp_str.data ) )
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function
end extern