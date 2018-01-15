/' path conversion '/

#include "fb.bi"

extern "C"
sub fb_hConvertPath( path as ubyte ptr )
	dim as ssize_t i, _len

	DBG_ASSERT( path <> NULL )

	_len = strlen( path )
	for i = 0 to _len - 1
#if defined( HOST_DOS ) or defined( HOST_XBOX )
		if ( path[i] = asc("/") ) then
			path[i] = asc("\")
		end if
#else
		if ( path[i] = asc("\") and path[i + 1] = asc("\") ) then
			path[i] = asc("/")
		end if
#endif
	next
end sub
end extern
