/' temp result string allocation '/

#include "fb.bi"

/':::::'/
extern "C"
function fb_StrAllocTempResult FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dsc

	FB_STRLOCK()

	/' alloc a temporary descriptor (the current one at stack will be trashed) '/
	dsc = fb_hStrAllocTempDesc( )
	if ( dsc = NULL ) then
		FB_STRUNLOCK()
		return @__fb_ctx.null_desc
	end if

	/' copy just the descriptor, setting it as a temp string '/
	dsc->data = src->data
	dsc->len  = src->len or FB_TEMPSTRBIT
	dsc->size = src->size

	/' just for safety.. '/
	src->data = NULL
	src->len  = 0
	src->size = 0

	FB_STRUNLOCK()

	return dsc
end function
end extern