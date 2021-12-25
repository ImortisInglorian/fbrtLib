/' misc string routines '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_SPACE FBCALL ( _len as ssize_t, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst

	DBG_ASSERT( result <> NULL )

	if ( _len > 0 ) then
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			/' fill it '/
			memset( dst.data, asc(" "), _len )

			/' null char '/
			dst.data[_len] = 0
		end if
	end if

	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern