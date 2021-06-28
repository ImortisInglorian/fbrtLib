/' DATA core '/

#include "fb.bi"

dim shared as FB_DATADESC ptr __fb_data_ptr = NULL

extern "C"
private sub hSkipLink( )
	/' If a link was reached, move to the next non-link, or NULL ("EOF") '/
	while ( __fb_data_ptr <> NULL andalso (__fb_data_ptr->len = FB_DATATYPE_LINK) ) 
		__fb_data_ptr = __fb_data_ptr->next
	wend

	DBG_ASSERT( (__fb_data_ptr = NULL) orelse (__fb_data_ptr->len <> FB_DATATYPE_LINK) )
end sub

sub fb_DataRestore FBCALL ( labeladdr as FB_DATADESC ptr )
	FB_LOCK()

	__fb_data_ptr = labeladdr
	hSkipLink( )

	FB_UNLOCK()
end sub

/' Callers are expected to FB_LOCK/FB_UNLOCK '/
sub fb_DataNext( )
	/' Move forward in current DATA table, if any '/
	if ( __fb_data_ptr <> NULL ) then
		DBG_ASSERT( __fb_data_ptr->len <> FB_DATATYPE_LINK )
		__fb_data_ptr += 1
		hSkipLink( )
	end if
end sub
end extern