/' SHELL command '/

#include "../fb.bi"

extern "C"
function fb_hShell( program as ubyte ptr ) as long
	return system_( program )
end function
end extern