/' leftself statement '/

#include "fb.bi"

extern "C"
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