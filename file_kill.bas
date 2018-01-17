/' kill function '/

#include "fb.bi"
#include "crt/errno.bi"

/':::::'/
extern "C"
function fb_FileKill FBCALL ( _str as FBSTRING ptr ) as long
	dim as long res = 0, _err = 0

	if ( _str->data <> NULL ) then
		res = remove( _str->data )
		_err = errno
	end if

	/' del if temp '/
	fb_hStrDelTemp( _str )
	
	if ( res = 0 ) then
		res = FB_RTERROR_OK
	else
		select case (_err)
			case ENOENT:
				res = FB_RTERROR_FILENOTFOUND
			case EACCES:
				res = FB_RTERROR_FILEIO
			case EPERM:
				res = FB_RTERROR_NOPRIVILEGES
			default:
				res = FB_RTERROR_ILLEGALFUNCTIONCALL
		end select
	end if

	return fb_ErrorSetNum( res )
end function
end extern