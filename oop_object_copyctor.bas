#include "fb.bi"

extern "C"
/' constructor fb_Object$( byref rhs as const fb_Object$ ) '/
sub _ZN10fb_ObjectC1ERKS_ alias "_ZN10fb_Object$C1ERKS_"( this_ as FB_OBJECT ptr, rhs as const FB_OBJECT ptr )
	/' Just initialize the vptr properly (we cannot just copy it from the
	   rhs, because that may really be a different object type that just was
	   up-casted), nothing else to do. '/
	_ZN10fb_ObjectC1Ev( this_ )
end sub
end extern