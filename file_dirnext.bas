/' dir() '/

#include "fb.bi"

extern "C"
function fb_DirNext FBCALL ( attrib as long ptr ) as FBSTRING ptr
	static as FBSTRING fname = ( 0, 0, 0 )
	return fb_Dir( @fname, 0, attrib )
end function
end extern