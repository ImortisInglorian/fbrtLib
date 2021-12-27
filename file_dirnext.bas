/' dir() '/

#include "fb.bi"

extern "C"
function fb_DirNext FBCALL ( attrib as long ptr, result as FBSTRING ptr ) as FBSTRING ptr
	static as FBSTRING fname = ( 0, 0, 0 )
	DBG_ASSERT( result <> NULL )
	return fb_Dir( @fname, 0, attrib, result )
end function
end extern