/' recover stdio after redirection '/

#include "fb.bi"

/' streamno:
   0   Reset stdin
   1   Reset stdout '/
extern "C"
sub fb_FileResetEx FBCALL ( streamno as long )
	dim as long errnum

	FB_LOCK()

	select case ( streamno )
		case 0, 1:
			errnum = iif(fb_hFileResetEx( streamno ) <> 0, FB_RTERROR_OK, FB_RTERROR_FILEIO)
		case else:
			errnum = FB_RTERROR_ILLEGALFUNCTIONCALL
	end select

	FB_UNLOCK()

	fb_ErrorSetNum( errnum )
end sub
end extern