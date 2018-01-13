/' path conversion '/

#include "fb.bi"

extern "C"
sub fb_hConvertPath( path as ubyte ptr )
	dim as ssize_t i, _len

	DBG_ASSERT( path <> NULL )

	_len = strlen( path )
	for i = 0 to _len - 1
#if defined( HOST_DOS ) or defined( HOST_XBOX )
		if ( path[i] = 47 ) then
			path[i] = sadd("\\")
		end if
#else
		if ( path[i] = 92 and path[i + 1] = 92 ) then
			path[i] = 47
		end if
#endif
	next
end sub
end extern