/' ltrim$ ANY function '/

#include "fb.bi"

extern "C"
function fb_LTrimAny FBCALL ( src as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
   dim as ubyte ptr pachText = NULL
	dim as FBSTRING ptr dst
	dim as ssize_t _len

	if ( src = NULL ) then
		fb_hStrDelTemp( pattern )
		return @__fb_ctx.null_desc
	end if

   FB_STRLOCK()
	
	_len = 0
	if ( src->data <> NULL ) then
      dim as ssize_t len_pattern = iif((pattern <> NULL) and (pattern->data <> NULL), FB_STRSIZE( pattern ), 0)
      pachText = src->data
      _len = FB_STRSIZE( src )
		if ( len_pattern <> 0 ) then
			while ( _len <> 0 )
				dim as ssize_t i
				for i = 0 to len_pattern
					if ( FB_MEMCHR( pattern->data, *pachText, len_pattern ) <> NULL ) then
						exit for
					end if
				next
	            
				if ( i = len_pattern ) then
					exit while
				end if
            
	         _len -= 1
	         pachText += 1
			wend
		end if
	end if

	if ( _len > 0 ) then
		/' alloc temp string '/
      dst = fb_hStrAllocTemp_NoLock( NULL, _len )
		if ( dst <> NULL ) then
			/' simple copy '/
			fb_hStrCopy( dst->data, pachText, _len )
		else
			dst = @__fb_ctx.null_desc
		end if
	else
		dst = @__fb_ctx.null_desc
	end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )
   fb_hStrDelTemp_NoLock( pattern )

   FB_STRUNLOCK()
	
	return dst
end function
end extern