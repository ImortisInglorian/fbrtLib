/' read stmt for long integer's '/

#include "fb.bi"

extern "C"
sub fb_DataReadLongint FBCALL ( dst as longint ptr )
	FB_LOCK()

	if( __fb_data_ptr <> NULL ) then
		if( __fb_data_ptr->len = FB_DATATYPE_OFS ) then
			*dst = cast(size_t, __fb_data_ptr->ofs)
		elseif ( __fb_data_ptr->len <> 0 and FB_DATATYPE_WSTR <> 0 ) then
			*dst = fb_WstrToLongint( __fb_data_ptr->wstr, __fb_data_ptr->len and &h7FFF )
		else
			*dst = fb_hStr2Longint( __fb_data_ptr->zstr, __fb_data_ptr->len )
		end if
	else
		/' no more DATA '/
		*dst = 0
	end if

	fb_DataNext( )

	FB_UNLOCK()
end sub
end extern