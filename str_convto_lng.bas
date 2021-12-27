/' str$ routines for longint, ulongint
 *
 * the result string's len is being "faked" to appear as if it were shorter
 * than the one that has to be allocated to fit _itoa and _gvct buffers.
 '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_LongintToStr FBCALL ( num as longint, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	/' alloc temp string '/
	if ( fb_hStrAlloc( @dst, sizeof( longint ) * 3 ) <> NULL ) then
		/' convert '/
#ifdef HOST_WIN32
		_i64toa( num, dst.data, 10 )
#else
		sprintf( dst.data, "%lld", num )
#endif

		fb_hStrSetLength( @dst, strlen( dst.data ) )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function

/':::::'/
function fb_ULongintToStr FBCALL ( num as ulongint, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( fb_hStrAlloc( @dst, sizeof( ulongint ) * 3 ) <> NULL ) then
		/' convert '/
#ifdef HOST_WIN32
		_ui64toa( num, dst.data, 10 )
#else
		sprintf( dst.data, "%llu", num )
#endif

		fb_hStrSetLength( @dst, strlen( dst.data ) )
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern