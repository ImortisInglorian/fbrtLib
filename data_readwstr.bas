/' read stmt for wstring's '/

#include "fb.bi"

extern "C"
sub fb_DataReadWstr FBCALL ( dst as FB_WCHAR ptr, dst_size as ssize_t )
	FB_LOCK()

	if ( __fb_data_ptr <> NULL ) then
		if ( __fb_data_ptr->len = FB_DATATYPE_OFS ) then
			/' !!!WRITEME!!! '/
		elseif ( __fb_data_ptr->len and FB_DATATYPE_WSTR ) then
			fb_WstrAssign( dst, dst_size, __fb_data_ptr->wstr )
		else
			fb_WstrAssignFromA( dst, dst_size, __fb_data_ptr->zstr, __fb_data_ptr->len )
		end if
	else
		/' no more DATA, return empty string '/
		fb_WstrAssign( dst, dst_size, cast(FB_WCHAR ptr, sadd("")) )
	end if

	fb_DataNext( )

	FB_UNLOCK()
end sub
end extern