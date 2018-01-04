/' read stmt for boolean's '/

#include "fb.bi"

/':::::'/
extern "C"
sub fb_DataReadBool FBCALL ( dst as boolean ptr )
	FB_LOCK()

	if ( __fb_data_ptr <> NULL ) then
		if ( __fb_data_ptr->len = FB_DATATYPE_OFS ) then
			*dst = cast(size_t, __fb_data_ptr->ofs)
		elseif ( __fb_data_ptr->len and FB_DATATYPE_WSTR ) then
			*dst = fb_WstrToBool( __fb_data_ptr->wstr, __fb_data_ptr->len and &h7FFF )
		else
			*dst = fb_hStr2Bool( __fb_data_ptr->zstr, __fb_data_ptr->len )
		end if
	else
		/' no more DATA '/
		*dst = 0
	end if

	fb_DataNext( )

	FB_UNLOCK()
end sub
end extern