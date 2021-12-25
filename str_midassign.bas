/' mid$ statement '/

#include "fb.bi"

extern "C"
sub fb_StrAssignMid FBCALL ( dst as FBSTRING ptr, start as ssize_t, _len as ssize_t, src as FBSTRING ptr )
	dim as ssize_t src_len, dst_len

	if ( (dst = NULL) orelse (dst->data = NULL) orelse (FB_STRSIZE( dst ) = 0) ) then
		exit sub
	end if

	if ( (src = NULL) orelse (src->data = NULL) orelse (FB_STRSIZE( src ) = 0) ) then
		exit sub 
	end if

	src_len = FB_STRSIZE( src )
	dst_len = FB_STRSIZE( dst )

	if ( (start > 0) andalso (start <= dst_len) andalso (_len <> 0) ) then
		start -= 1

		if ( (_len < 0) orelse (_len > src_len) ) then
			_len = src_len
		end if

	if ( ( start + _len ) > dst_len ) then
		_len = (dst_len - start)
	end if
		
	memcpy( dst->data + start, src->data, _len )
   end if
end sub
end extern