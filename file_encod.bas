/' string to file encoding function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_hFileStrToEncoding( _encoding as ubyte ptr ) as FB_FILE_ENCOD
	if ( _encoding = NULL ) then
		return FB_FILE_ENCOD_DEFAULT
	end if

	if ( strncasecmp( _encoding, "UTF", 3 ) = 0 ) then
		_encoding += 3

		if ( *_encoding = asc("-") ) then
			_encoding += 1
		end if
		
		if ( *_encoding = asc("8") ) then
			return FB_FILE_ENCOD_UTF8
		end if

		if ( strcmp( _encoding, "16" ) = 0 ) then
			return FB_FILE_ENCOD_UTF16
		end if

		if ( strcmp( _encoding, "32" ) = 0 ) then
			return FB_FILE_ENCOD_UTF32
		end if
	else
		if ( strncasecmp( _encoding, "ASC", 3 ) = 0 ) then
			return FB_FILE_ENCOD_ASCII
		end if
	end if

	return FB_FILE_ENCOD_DEFAULT
end function
end extern