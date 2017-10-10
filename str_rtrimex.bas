/' enhanced rtrim$ function '/

#include "fb.bi"

extern"C"
function fb_RTrimEx FBCALL ( src as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t _len

    if ( src = NULL ) then
        fb_hStrDelTemp( pattern )
        return @__fb_ctx.null_desc
    end if

   	FB_STRLOCK()

	if ( src->data <> NULL ) then
		dim as ssize_t len_pattern = iif((pattern <> NULL) and (pattern->data <> NULL), FB_STRSIZE( pattern ), 0)
		_len = FB_STRSIZE( src )
		if ( _len >= len_pattern ) then
            if ( len_pattern = 1 ) then
                dim as ubyte ptr src_ptr = fb_hStrSkipCharRev( src->data, _len, FB_CHAR_TO_INT(pattern->data[0]) )
                _len = cast(ssize_t, (src_ptr - src->data) + 1)
            elseif ( len_pattern <> 0 ) then
                dim as ubyte ptr src_ptr = src->data
                dim as ssize_t test_index = _len - len_pattern
                while (_len >= len_pattern )
                    if ( FB_MEMCMP( src_ptr + test_index, pattern->data, len_pattern ) <> 0 ) then
                        exit while
					end if
                    test_index -= len_pattern
                wend
                _len = test_index + len_pattern
            end if
		end if
    else 
        _len = 0
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
	fb_hStrDelTemp_NoLock( pattern )

   	FB_STRUNLOCK()

	return dst
end function
end extern