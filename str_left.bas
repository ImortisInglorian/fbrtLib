/' left$ function '/

#include "fb.bi"

extern "C"
function fb_LEFT FBCALL ( src as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t _len, src_len

	if ( src = NULL ) then
		return @__fb_ctx.null_desc
	end if

	FB_STRLOCK()

	src_len = FB_STRSIZE( src )
	if ( (src->data <> NULL) and (chars > 0) and (src_len > 0) ) then
		if ( chars > src_len ) then
			_len = src_len
		else
			_len = chars
		end if

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

/' 
	Special case of a = left( a, n )
	The string 'a' is not reallocated, only the string length field is adjusted
	and a NUL terminator written. fbc does not optimize for this so to use,
	it must be a direct call by the user.  Careful, due the function declaration, it
	does not check for fb_LEFTSELF( "literal", n ) so if src is a temporary,
	it just gets deleted.
'/
sub fb_LEFTSELF FBCALL ( src as FBSTRING ptr, chars as ssize_t )
	dim as ssize_t src_len

	if ( src = NULL ) then
		exit sub
	end if

	FB_STRLOCK()

	src_len = FB_STRSIZE( src )
	if( (src->data <> NULL)	andalso (chars >= 0) andalso (src_len >= 0) ) then
		if( chars > src_len ) then
			fb_hStrSetLength( src, src_len )
			/' add a NUL character '/
			src->data[src_len] = 0
		else
			fb_hStrSetLength( src, chars )
			/' add a NUL character '/
			src->data[chars] = 0
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )

	FB_STRUNLOCK()
end sub
end extern