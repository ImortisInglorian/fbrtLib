/' assertion functions '/

#include "fb.bi"

#define BUFFER_SIZE 1024

extern "C"
sub hConvToA( buffer as ubyte ptr, expression as FB_WCHAR ptr )
	fb_wstr_ConvToA( buffer, BUFFER_SIZE-1, expression )
	buffer[BUFFER_SIZE-1] = 0 /' null terminator '/
end sub

sub fb_AssertW FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as FB_WCHAR ptr )
	dim as ubyte buffer(0 to BUFFER_SIZE - 1)

	/' Convert the expression wstring to a zstring '/
	hConvToA( @buffer(0), expression )

	/' then let the zstring version handle it '/
	fb_Assert( filename, linenum, funcname, @buffer(0) )

	/' This way we don't need to bother using fwprintf() or similar,
	   which would only make things unnecessarily complex,
	   especially since it doesn't exist on DJGPP. '/
end sub

sub fb_AssertWarnW FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as FB_WCHAR ptr )
	dim as ubyte buffer(0 to BUFFER_SIZE - 1)
	hConvToA( @buffer(0), expression )
	fb_AssertWarn( filename, linenum, funcname, @buffer(0) )
end sub
end extern