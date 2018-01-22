/' detects EOF for file device '/

#include "fb.bi"

extern "C"
sub fb_DevScrnFillInput( info as DEV_SCRN_INFO ptr )
    dim as FBSTRING ptr _str
    dim as size_t _len = 0

    _str = fb_Inkey( )
    if ( _str <> NULL ) then
    	_len = FB_STRSIZE( _str )
	    if ( (_str->data <> NULL) and (_len > 0) ) then
	    	DBG_ASSERT(_len < sizeof(info->buffer))
    		/' copy null-term too '/
    		memcpy( @info->buffer(0), _str->data, _len+1 )
    	end if

    	fb_hStrDelTemp( _str )
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