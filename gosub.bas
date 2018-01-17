/' GOSUB support '/

#include "fb.bi"
#include "crt/setjmp.bi"

/' slow but easy to manage dynamic GOSUB call-stack '/
type gosubnode 
	as jmp_buf buf
	as gosubnode ptr next
end type

/' the gosub context allocated in auto-local storage by the compiler '/
type GOSUBCTX
	as GOSUBNODE ptr top
end type

/'
	NOTES:
		On the compiler side, GOSUBCTX is an ANY PTR.  To extend 
		GOSUBCTX, the compiler must allocate additional	space for 
		the GOSUBCTX pseudo-object.

		GOSUBCTX does not have a constructor, but it is expected that
		the compiler will initialize the variable to zero.

		See ast-gosub.bas::astGosubAddInit()
'/

extern "C"
/':::::'/
function fb_GosubPush FBCALL ( ctx as GOSUBCTX ptr ) as any ptr
	dim as GOSUBNODE ptr node = malloc( sizeof( GOSUBNODE ) )
	node->next = ctx->top
	ctx->top = node

	/' returns address of ctx->top->buf	'/
	return @(ctx->top->buf)
end function

/':::::'/
function fb_GosubPop FBCALL ( ctx as GOSUBCTX ptr ) as long
	if ( ctx <> NULL and  ctx->top <> NULL ) then
		dim as GOSUBNODE ptr node = ctx->top->next
		free(ctx->top)
		ctx->top = node

		/' return success '/
		return fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	/' don't know where to go next so return an error '/
	return fb_ErrorSetNum( FB_RTERROR_RETURNWITHOUTGOSUB )
end function

/':::::'/
function fb_GosubReturn FBCALL ( ctx as GOSUBCTX ptr ) as long
	if ( ctx <> NULL and ctx->top <> NULL ) then
		dim as GOSUBNODE ptr node = ctx->top->next
		
		/' TODO: with a different stack allocation strategy, this
		 * temporary copy won't be needed '/
		dim as jmp_buf buf
		FB_MEMCPY( @buf, @ctx->top->buf, sizeof(jmp_buf))

		free(ctx->top)
		ctx->top = node

		longjmp( @buf, -1 )
	end if

	/' don't know where to go next so return an error '/
	return fb_ErrorSetNum( FB_RTERROR_RETURNWITHOUTGOSUB )
end function

/':::::'/
sub fb_GosubExit FBCALL ( ctx as GOSUBCTX ptr )
	if ( ctx <> NULL ) then
		while ( ctx->top <> NULL )
			dim as GOSUBNODE ptr node = ctx->top->next
			free(ctx->top)
			ctx->top = node
		wend
	end if
end sub
end extern