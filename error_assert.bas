/' assertion functions '/

#include "fb.bi"

extern "C"
sub fb_Assert FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as ubyte ptr )
	snprintf( @__fb_errmsg(0), FB_ERRMSG_SIZE, _
	          "%s(%d): assertion failed at %s: %s\n", _
	          filename, linenum, funcname, expression )

	__fb_errmsg(FB_ERRMSG_SIZE-1) = 0

	/' Let fb_hRtExit() show the message '/
	__fb_ctx.errmsg = @__fb_errmsg(0)

	fb_End( 1 )
end sub

sub fb_AssertWarn FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as ubyte ptr )
	/' Printing to stderr, as done with assert() or runtime error messages
	   in fb_hRtExit() '/
	fprintf( stderr, "%s(%d): assertion failed at %s: %s\n", _
	         filename, linenum, funcname, expression )
end sub
end extern