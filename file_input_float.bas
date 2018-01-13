/' input function for float's and double's '/

#include "fb.bi"

extern "C"
function fb_InputSingle FBCALL ( dst as single ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		if ( _len <= FB_INPUT_MAXINTLEN ) then
			*dst = cast(single, fb_hStr2Int( @buffer(0), _len ))
		elseif ( _len <= FB_INPUT_MAXLONGLEN ) then
			*dst = cast(single, fb_hStr2Longint( @buffer(0), _len ))
		else
			if ( buffer(0) = 38 ) then
				*dst = cast(single, fb_hStr2Longint( @buffer(0), _len ))
			else
				*dst = strtof( @buffer(0), NULL )
			end if
		end if
	else
		*dst = strtof( @buffer(0), NULL )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_InputDouble FBCALL( dst as double ptr ) as long
    dim as ubyte buffer(0 to FB_INPUT_MAXNUMERICLEN)
	dim as ssize_t _len
	dim as long isfp

	_len = fb_FileInputNextToken( @buffer(0), FB_INPUT_MAXNUMERICLEN, FB_FALSE, @isfp )

	if ( isfp = FALSE ) then
		if ( _len <= FB_INPUT_MAXINTLEN ) then
			*dst = cast(double, fb_hStr2Int( @buffer(0), _len ))
		elseif ( _len <= FB_INPUT_MAXLONGLEN ) then
			*dst = cast(double, fb_hStr2Longint( @buffer(0), _len ))
		else
			if ( buffer(0) = 38 ) then
				*dst = cast(double, fb_hStr2Longint( @buffer(0), _len ))
			else
				*dst = strtod( @buffer(0), NULL )
			end if
		end if
	else
		*dst = strtod( @buffer(0), NULL )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern