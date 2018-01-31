/' is operator '/

#include "fb.bi"

extern "C"
function fb_IsTypeOf FBCALL ( obj as FB_OBJECT ptr, typeRTTI as FB_RTTI ptr ) as long
	if ( obj = NULL ) then
		return FB_FALSE
	end if
	
	dim as FB_RTTI ptr objRTTI = cast(FB_BASEVT ptr,((cast(ubyte ptr, obj->pVT))- sizeof( FB_BASEVT )))->pRTTI 
	while ( objRTTI <> NULL )
		/' note: can't compare just the address because object or type could be declared in a DLL '/
		if ( strcmp( objRTTI->id, typeRTTI->id ) = 0 ) then
			return FB_TRUE
		end if
			
		objRTTI = objRTTI->pRTTIBase
	wend
	
	return FB_FALSE
end function
end extern