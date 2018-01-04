/' UTF-encoded file device LINE INPUT for strings '/

#include "fb.bi"

extern "C"
function fb_DevFileReadLineEncod( handle as FB_FILE ptr, dst as FBSTRING ptr ) as long
	dim as long res

	FB_LOCK()

	dim as FILE ptr fp = cast(FILE ptr, handle->opaque)
	
	if ( fp = stdout or fp = stderr ) then
		fp = stdin
	end if

	if ( fp = NULL ) then
		FB_UNLOCK()
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' Clear string first, we're only using += concat assign below... '/
	fb_StrDelete( dst )

	/' Read one byte at a time until CR and/or LF is found.
	   The fb_FileGetDataEx() will handle the decoding. '/
	while ( TRUE )
		dim as ubyte ptr c(0 to 1)
		dim as size_t _len

		res = fb_FileGetDataEx( handle, 0, @c(0), 1, @_len, FALSE, FALSE )
		if ( (res <> FB_RTERROR_OK) or (_len = 0) ) then
			exit while
		end if

		/' CR? Check for following LF too, and skip it if it's there '/
		if ( c(0) = 13) then
			res = fb_FileGetDataEx( handle, 0, @c(0), 1, @_len, FALSE, FALSE )
			if ( (res <> FB_RTERROR_OK) or (_len = 0) ) then
				exit while
			end if

			/' No LF? Ok then, don't skip it yet '/
			if ( c(0) <> 10 ) then
				fb_FilePutBackEx( handle, @c(0), 1 )
			end if

			exit while
		end if

		/' LF? '/
		if ( c(0) = 10 ) then
			exit while
		end if

		/' Any other char? Append to string, and continue... '/
		c(1) = 0
		fb_StrConcatAssign( cast(any ptr, dst), -1, @c(0), 1, FB_FALSE )
	wend

	FB_UNLOCK()

	return res
end function
end extern