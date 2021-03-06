/' flush file buffers to disk (or writable device)'/

#include "fb.bi"

extern "C"

function fb_FileFlushEx( handle as FB_FILE ptr, systembuffers as long ) as long
	dim as long res

	FB_LOCK()

	if( FB_HANDLE_USED(handle) = 0 ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	select case( handle->mode )
		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM, FB_FILE_MODE_OUTPUT, FB_FILE_MODE_APPEND:
			' Do nothing
		case else:
			FB_UNLOCK()
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end select

	if( handle->hooks andalso handle->hooks->pfnFlush ) then
		res = handle->hooks->pfnFlush( handle )
		if( res = FB_RTERROR_OK andalso systembuffers <> 0 ) then
			res = fb_hFileFlushEx( cast(file ptr, handle->opaque) )
		end if
	else
		res = fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	FB_UNLOCK()

	return res
end function

/'::::'/
sub fb_FileFlushAll FBCALL ( systembuffers as long )
	dim as long i = 1

	FB_LOCK()

	while( i <= FB_MAX_FILES - FB_RESERVED_FILES )
		dim as FB_FILE ptr handle = FB_FILE_TO_HANDLE_VALID( i )
		if( handle->hooks andalso handle->hooks->pfnFlush ) then
			dim as long res = handle->hooks->pfnFlush( handle )
			if( res = FB_RTERROR_OK andalso systembuffers <> 0 ) then
				fb_hFileFlushEx( cast(FILE ptr, handle->opaque) )
			end if
		end if
		i += 1
	wend

	FB_UNLOCK()
end sub

/':::::'/
function fb_FileFlush FBCALL ( fnum as long, systembuffers as long ) as long
	if fnum = -1 then
		fb_FileFlushAll( systembuffers )
		return fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	return fb_FileFlushEx(FB_FILE_TO_HANDLE(fnum), systembuffers )
end function

end extern
