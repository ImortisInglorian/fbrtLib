/' QB compatible OPEN '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_FileOpenQB FBCALL ( _str as FBSTRING ptr, mode as ulong, access_ as ulong, _lock as ulong, fnum as long, _len as long ) as long
	if ( FB_FILE_INDEX_VALID( fnum ) = NULL ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	dim as ssize_t str_len = FB_STRSIZE( _str )

	if ( str_len = 0 or (_str->data = NULL) ) then
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if
		
	/' serial? '/
	if ( (str_len > 3) and (strncasecmp( _str->data, "COM", 3 ) = 0) ) then
		dim as ssize_t i = 3
		while( (i < str_len) and (_str->data[i] >= asc("0")) and (_str->data[i] <= asc("9") ) )
			i += 1
		wend

		if ( _str->data[i] = asc(":") ) then
			return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
									 _str, _
									 mode, _
									 access_, _
									 _lock, _
									 _len, _
									 FB_FILE_ENCOD_ASCII, _
									 @fb_DevComOpen )
		end if
	/' parallel? '/
	elseif ( (str_len > 3) and (strncasecmp( _str->data, "LPT", 3 ) = 0) ) then
		dim as ssize_t i = 3
		while( (i < str_len) and (_str->data[i] >= asc("0")) and (_str->data[i] <= asc("9") ) )
			i += 1
		wend

		if ( _str->data[i] = asc(":") ) then
			return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
									 _str, _
									 mode, _
									 access_, _
									 _lock, _
									 _len, _
									 FB_FILE_ENCOD_ASCII, _
									 @fb_DevLptOpen )
		end if
	/' default printer? '/
	elseif ( (str_len = 4) and (strcasecmp( _str->data, "PRN:" ) = 0) ) then
		return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
								 _str, _
								 mode, _
								 access_, _
								 _lock, _
								 _len, _
								 FB_FILE_ENCOD_ASCII, _
								 @fb_DevLptOpen )
	/' console? '/
	elseif ( (str_len = 5) and (strcasecmp( _str->data, "CONS:" ) = 0) ) then
		return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
								 _str, _
								 mode, _
								 access_, _
								 _lock, _
								 _len, _
								 FB_FILE_ENCOD_ASCII, _
								 @fb_DevConsOpen )

	/' screen? '/
	elseif ( (str_len = 5) and (strcasecmp( _str->data, "SCRN:" ) = 0) ) then
		fb_DevScrnInit( )
	
		return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
								 _str, _
								 mode, _
								 access_, _
								 _lock, _
								 _len, _
								 FB_FILE_ENCOD_ASCII, _
								 @fb_DevScrnOpen )
	/' pipe? '/
	elseif ( (str_len >= 5) and (strncasecmp( _str->data, "PIPE:", 5 ) = 0) ) then
		dim as destructable_string tmp
		return fb_FileOpenVfsEx( FB_FILE_TO_HANDLE(fnum), _
								 fb_StrMid( _str, 6, str_len - 5, @tmp ), _
								 mode, _
								 access_, _
								 _lock, _
								 _len, _
								 FB_FILE_ENCOD_ASCII, _
								 @fb_DevPipeOpen )
	end if
	
	/' ordinary file '/
	return fb_FileOpenEx( FB_FILE_TO_HANDLE(fnum), _str, mode, access_, _lock, _len )
end function
end extern
