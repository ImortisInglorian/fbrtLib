/' file device '/

#include "fb.bi"

extern "C"
function fb_DevFileReadWstr( handle as FB_FILE ptr, dst as FB_WCHAR ptr, pchars as size_t ptr ) as long
	dim as FILE ptr fp
	dim as size_t chars
	dim as ubyte ptr buffer
        dim as long errorRet = FB_RTERROR_OK

	FB_LOCK()

	if ( handle = NULL ) then
		fp = stdin
	else
		fp = cast(FILE ptr, handle->opaque)
		if ( fp = stdout orelse fp = stderr ) then
			fp = stdin
		end if

		if ( fp = NULL ) then
			errorRet = FB_RTERROR_ILLEGALFUNCTIONCALL
			goto functionExit
		end if
	end if

	chars = *pchars

	buffer = allocate( chars + 1 )
        if ( buffer = Null ) then 
		errorRet = FB_RTERROR_ILLEGALFUNCTIONCALL
		goto functionExit
	end if

	/' do read '/
	chars = fread( buffer, 1, chars, fp )
	buffer[chars] = 0

	/' convert to wchar, file should be opened with the ENCODING option
	   to allow UTF characters to be read '/
	fb_wstr_ConvFromA( dst, chars, buffer )

	deallocate( buffer )

	/' fill with nulls if at eof '/
	if ( chars <> *pchars ) then
		memset( @dst[chars], 0, (*pchars - chars) * sizeof( FB_WCHAR ) )
	end if

	*pchars = chars

functionExit:
	FB_UNLOCK()

	return fb_ErrorSetNum( errorRet )
end function
end extern