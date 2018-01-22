/' file size '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_FileSizeEx( handle as FB_FILE ptr ) as fb_off_t
	dim as fb_off_t res = 0

	if( FB_HANDLE_USED(handle) = NULL ) then
		return res
	end if

	FB_LOCK()

	if (handle->hooks->pfnSeek <> NULL and handle->hooks->pfnTell <> NULL) then
		dim as fb_off_t old_pos
		/' remember old position '/
		dim as long result = handle->hooks->pfnTell(handle, @old_pos)
		if (result = 0) then
			/' move to end of file '/
			result = handle->hooks->pfnSeek(handle, 0, SEEK_END)
		end if
		if (result = 0) then
			/' get size '/
			result = handle->hooks->pfnTell(handle, @res)
			/' restore old position'/
			handle->hooks->pfnSeek(handle, old_pos, SEEK_SET)
		end if
	end if

	FB_UNLOCK()

	return res
end function

/':::::'/
function fb_FileSize FBCALL ( fnum as long ) as longint
	return fb_FileSizeEx(FB_FILE_TO_HANDLE(fnum))
end function
end extern