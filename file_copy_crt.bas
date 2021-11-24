/' generic C stdio file copy '/

#include "fb.bi"

#define BUFFER_SIZE 512

extern "C"
function fb_CrtFileCopy FBCALL ( source as const ubyte ptr, destination as const ubyte ptr ) as long
	dim as FILE ptr src, dst
	dim as ubyte buffer(0 to BUFFER_SIZE - 1)
	dim as ubyte ptr bufferPtr
	dim as size_t bytesread

	dst = NULL
	src = fopen(cast(ubyte ptr, source), "rb")
	if (src = 0) then
		goto _err
	end if

	dst = fopen(cast(ubyte ptr, destination), "wb")
	if (dst = 0) then
		goto _err
	end if
	
	bufferPtr = @buffer(0)
	While True
		bytesread = fread( bufferPtr, 1, BUFFER_SIZE, src )
		if ( bytesread > 0 ) Then
			if (fwrite( bufferPtr, 1, bytesread, dst ) <> bytesread) then
				goto _err
			end if
		else
			exit while
		end if
	wend

	if ( feof( src ) = 0 ) then
		goto _err
	end if

	fclose( src )
	fclose( dst )

	return fb_ErrorSetNum( FB_RTERROR_OK )

_err:
	if (src) then fclose( src )
	if (dst) then fclose( dst )
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern