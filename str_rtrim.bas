/' rtrim$ function '/

#include "fb.bi"

extern "C"
function fb_RTRIM FBCALL( src as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t _len

	if ( src = NULL ) then
		return @__fb_ctx.null_desc
	end if
	
   FB_STRLOCK()
	
	_len = 0
	if ( src->data <> NULL ) then
		_len = FB_STRSIZE( src )
		if ( _len > 0 ) then
			dim as ubyte ptr src_ptr = fb_hStrSkipCharRev( src->data, _len, 32 )
			_len = cast(ssize_t, (src_ptr - src->data)) + 1
		end if
	end if

	if ( _len > 0 ) then
		/' alloc temp string '/
      dst = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( dst <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst->data, src->data, _len )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )

	FB_STRUNLOCK()

	return dst
end function
end extern