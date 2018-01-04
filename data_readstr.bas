/' read stmt for strings '/

#include "fb.bi"

extern "C"
sub fb_DataReadStr FBCALL ( dst as any ptr, dst_size as ssize_t, fillrem as long )
	FB_LOCK()

	if ( __fb_data_ptr <> NULL ) then
		if ( __fb_data_ptr->len = FB_DATATYPE_OFS ) then
			/' !!!WRITEME!!! '/
		elseif ( __fb_data_ptr->len and FB_DATATYPE_WSTR ) then
			fb_WstrAssignToA( dst, dst_size, __fb_data_ptr->wstr, fillrem )
		else
			fb_StrAssign( dst, dst_size, __fb_data_ptr->zstr, 0, fillrem )
		end if
	else
		/' no more DATA, return empty string '/
		fb_StrAssign( dst, dst_size, sadd(""), 0, fillrem )
	end if

	fb_DataNext( )

	FB_UNLOCK()
end sub
end extern