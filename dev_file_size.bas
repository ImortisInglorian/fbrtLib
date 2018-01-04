/' file device size calc '/

#include "fb.bi"
#include "crt_extra/stdio.bi"

extern "C"
function fb_hDevFileSeekStart( fp as FILE ptr, mode as long, encod as FB_FILE_ENCOD, seek_zero as long ) as long
	/' skip the BOM if in UTF-mode '/
	dim as size_t ofs

	select case ( encod )
		case FB_FILE_ENCOD_UTF8:
			ofs = 3

		case FB_FILE_ENCOD_UTF16:
			ofs = sizeof( UTF_16 )

		case FB_FILE_ENCOD_UTF32:
			ofs = sizeof( UTF_32 )

		case else:
			if ( seek_zero = FALSE ) then
				return 0
			end if

			ofs = 0
	end select

	return fseeko( fp, ofs, SEEK_SET )
end function

function fb_DevFileGetSize( fp as FILE ptr, mode as long, encod as FB_FILE_ENCOD, seek_back as long ) as fb_off_t
	dim as fb_off_t size = 0

	select case ( mode )
		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM, FB_FILE_MODE_INPUT:

			if ( fseeko( fp, 0, SEEK_END ) <> 0 ) then
				return -1
			end if

			size = ftello( fp )

			if ( seek_back ) then
				fb_hDevFileSeekStart( fp, mode, encod, TRUE )
			end if

		case FB_FILE_MODE_APPEND:
			size = ftello( fp )
	end select

	return size
end function
end extern