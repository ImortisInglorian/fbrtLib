/' input function '/

#include "fb.bi"

extern "C"
function fb_ConsoleInput FBCALL ( text as FBSTRING ptr, addquestion as long, addnewline as long ) as long
	dim as FB_INPUTCTX ptr ctx
	dim as long res

	fb_DevScrnInit_Read( )

	if ( fb_IsRedirected( TRUE ) <> NULL ) then
		/' del if temp '/
		fb_hStrDelTemp( text )

		return fb_FileInput( 0 )
	end if

	ctx = _FB_TLSGETCTX( INPUT )

	fb_StrDelete( @ctx->str )
	ctx->handle = 0
	ctx->status = 0
	ctx->index = 0

	res = fb_LineInput( text, @ctx->str, -1, 0, addquestion, addnewline )

	return res
end function
end extern