/' serial port access stubs '/

#include "../fb.bi"

extern "C"
function fb_SerialOpen ( handle as FB_FILE ptr, iPort as long, options as FB_SERIAL_OPTIONS ptr, pszDevice as ubyte ptr, ppvHandle as any ptr ptr ) as long
   return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

function fb_SerialGetRemaining ( handle as FB_FILE ptr, pvHandle as any ptr, pLength as fb_off_t ptr ) as long
   return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

function fb_SerialWrite ( handle as FB_FILE ptr, pvHandle as any ptr, _data as const any ptr, length as size_t ) as long
   return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

declare function fb_SerialRead ( handle as FB_FILE ptr, pvHandle as any ptr, _data as any ptr, pLength as size_t ptr ) as long
   return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function

declare function fb_SerialClose ( handle as FB_FILE ptr, pvHandle as any ptr ) as long
   return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern