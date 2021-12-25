/' detects EOF for file device '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
sub fb_DevScrnFillInput( info as DEV_SCRN_INFO ptr )
	dim as destructable_string _str
	dim as size_t _len = 0

	if ( fb_Inkey( @_str ) <> NULL ) then
		_len = _str.len
		if ( (_str.data <> NULL) and (_len > 0) ) then
			DBG_ASSERT(_len < sizeof( ARRAY_SIZEOF( info->buffer ) ))
			/' copy null-term too '/
			memcpy( @info->buffer(0), _str.data, _len+1 )
		end if
	end if

	info->length = _len
end sub

function fb_DevScrnEof( handle as FB_FILE ptr ) as long
	dim as DEV_SCRN_INFO ptr info
	dim as long got_data

	FB_LOCK()
	info = cast(DEV_SCRN_INFO ptr, FB_HANDLE_DEREF(handle)->opaque)
	got_data = (info->length <> 0)
	FB_UNLOCK()
	if ( got_data = NULL ) then
		FB_LOCK()
		fb_DevScrnFillInput( info )
		got_data = (info->length <> 0)
		FB_UNLOCK()
	end if
	return not(got_data)
end function
end extern