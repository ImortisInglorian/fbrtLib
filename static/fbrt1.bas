/' FB runtime initialization and cleanup

   We use a global constructor and destructor for this. Where possible they
   should run first/last respectively, such that it's safe for FB programs to
   use the FB runtime from inside its own global ctors/dtors. '/

#include "../fb.bi"

/' note: they must be static, or shared libraries in Linux would reuse the 
   same function '/

extern "C"
private sub fb_hDoInit( ) constructor 101
	fb_hRtInit( )
	fb_InitProfile( )
end sub

private sub fb_hDoExit( ) destructor 101
	fb_EndProfile( 0 )
	fb_hRtExit( )
end sub
end extern
