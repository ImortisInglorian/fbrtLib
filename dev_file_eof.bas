/' detects EOF for file device '/

#include "fb.bi"

extern "C"
function fb_DevFileEof( handle as FB_FILE ptr ) as long
    dim as FILE ptr fp

	FB_LOCK()

    fp = cast(FILE ptr, handle->opaque)

	if ( fp = NULL ) then
		FB_UNLOCK()
		return FB_TRUE
	end if

	dim as long eof__
	select case ( handle->mode )
		/' non-text mode? '/
		case FB_FILE_MODE_BINARY, FB_FILE_MODE_RANDOM:
			/' note: handle->putback_size will be checked by fb_FileEofEx() '/
			/' This detects both cases: a) last read reached EOF, b) next
			   read will reach EOF '/
			eof__ = (ftello( fp ) >= handle->size)

		/' text-mode (INPUT, OUTPUT or APPEND) '/
		case else:
			/' This also handles the EOF char (27). '/
			/' We can't check ftell(), because it's not guaranteed to give
			   a real file offset in text mode. '/
			/' a) detect whether last read reached EOF '/
			eof__ = feof( fp )
			if ( eof__ = 0 ) then
				/' b) peek ahead: will the next read reach EOF? '/
				dim as long c = getc( fp )
				eof__ = (c = EOF_)
				if ( eof__ = 0 ) then
					ungetc( c, fp )
				end if
			end if
	end select

	FB_UNLOCK()
	return iif(eof__ <> 0, FB_TRUE, FB_FALSE)
end function
end extern
