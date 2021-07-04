/' get # function for wstrings '/
#ifdef fb_FileGetWstr
	#undef fb_FileGetWstr
	#undef fb_FileGetWstrLarge
	#undef fb_FileGetWstrIOB
	#undef fb_FileGetWstrLargeIOB
#endif
#include "fb.bi"

extern "C"
function fb_FileGetWstrEx( handle as FB_FILE ptr, _pos as fb_off_t, dst as FB_WCHAR ptr, dst_chars as ssize_t, bytesread as size_t ptr ) as long
	if ( bytesread <> 0 ) then
		*bytesread = 0
	end if

	if( (FB_HANDLE_USED(handle) = 0) or (dst = 0) or (dst_chars < 0) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' may have to detect the length if given a dereferenced wstring ptr '/
	if ( dst_chars = 0 ) then
		dst_chars = fb_wstr_Len( dst ) + 1
	end if

	/' need room for at least 1 wchar and the null terminator '/
	/' (Get# on a wstring * 1, i.e. just room for the null terminator, is not supported,
	   same as for [z]strings) '/
	if ( dst_chars < 2 ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	/' Fill wchar buffer with raw bytes from the file. '/
	/' We request to read in multiples of sizeof(wchar), but EOF can be
	   reached at an odd number of bytes - fb_DevFileRead() will fill the
	   remainder with zeroes at least. '/
	dim as size_t rawbytesread
	dim as long res = fb_FileGetDataEx( handle, _pos, cast(any ptr, dst), (dst_chars - 1) * sizeof(FB_WCHAR), @rawbytesread, TRUE, FALSE )
	if ( res <> FB_RTERROR_OK ) then
		return res
	end if

	if (bytesread <> 0) then
		*bytesread = rawbytesread
	end if

	/' Add null-terminator '/
	dim as long extra = rawbytesread mod sizeof(FB_WCHAR)
	if (extra > 0) then
		rawbytesread += sizeof(FB_WCHAR) - extra /' round up '/
	end if
	DBG_ASSERT( (rawbytesread mod sizeof(FB_WCHAR)) = 0 )
	dst[rawbytesread / sizeof(FB_WCHAR)] = asc( !"\000" ) '' NUL CHAR

	return FB_RTERROR_OK
end function

function fb_FileGetWstr FBCALL ( fnum as long, _pos as long, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
	return fb_FileGetWstrEx( FB_FILE_TO_HANDLE(fnum), _pos, dst, dst_chars, NULL )
end function

function fb_FileGetWstrLarge FBCALL ( fnum as long, _pos as longint, dst as FB_WCHAR ptr, dst_chars as ssize_t ) as long
	return fb_FileGetWstrEx( FB_FILE_TO_HANDLE(fnum), _pos, dst, dst_chars, NULL )
end function

function fb_FileGetWstrIOB FBCALL ( fnum as long, _pos as long, dst as FB_WCHAR ptr, dst_chars as ssize_t, bytesread as size_t ptr ) as long
	return fb_FileGetWstrEx( FB_FILE_TO_HANDLE(fnum), _pos, dst, dst_chars, bytesread )
end function

function fb_FileGetWstrLargeIOB FBCALL ( fnum as long, _pos as longint, dst as FB_WCHAR ptr, dst_chars as ssize_t, bytesread as size_t ptr ) as long
	return fb_FileGetWstrEx( FB_FILE_TO_HANDLE(fnum), _pos, dst, dst_chars, bytesread )
end function
end extern