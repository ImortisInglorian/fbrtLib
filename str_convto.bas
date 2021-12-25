/' str$ routines for int, uint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_IntToStr FBCALL ( num as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, sizeof( long ) * 3 ) <> NULL ) then
		/' convert '/
		sprintf( dst.data, "%d", num )
		fb_hStrSetLength( @dst, strlen( dst.data ) )
	end if
	
	fb_StrSwapDesc( @dst, result )
	return result
end function

/':::::'/
function fb_UIntToStr FBCALL ( num as ulong, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, sizeof( ulong ) * 3 ) <> NULL ) then
		/' convert '/
#ifdef HOST_WIN32
		_ultoa( num, dst.data, 10 )
#else
		sprintf( dst->data, "%u", num )
#endif
		fb_hStrSetLength( @dst, strlen( dst.data ) )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern