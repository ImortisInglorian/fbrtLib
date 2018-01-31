/' SHELL command '/

#include "fb.bi"

extern "C"
function fb_Shell FBCALL ( program as FBSTRING ptr ) as long
	dim as long errcode = -1

	if ( program <> 0 and program->data <> NULL ) then
		errcode = fb_hShell( program->data )
	end if

	/' del if temp '/
	fb_hStrDelTemp( program )

	return errcode
end function
end extern