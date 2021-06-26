/' Object class methods '/

#include "fb.bi"

extern "C"
	extern as FB_RTTI __fb_ZTS6Object
	extern as FB_BASEVT Object_VT 

	dim shared as FB_RTTI __fb_ZTS6Object = ( NULL, sadd("6OBJECT"), NULL )
	dim shared as FB_BASEVT Object_VT = ( NULL, @__fb_ZTS6Object )

/' constructor fb_Object$( ) '/
sub _ZN10fb_ObjectC1Ev alias "_ZN10fb_Object$C1Ev"( this_ as FB_OBJECT ptr )
	this_->pVT = cast(FB_BASEVT ptr ,((cast(ubyte ptr, @Object_VT)) + sizeof( FB_BASEVT )))
end sub
end extern
