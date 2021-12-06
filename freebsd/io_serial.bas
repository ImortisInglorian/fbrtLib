/' serial port access stubs '/

#include "../fb.bi"

Extern "c"
Function fb_SerialOpen _
( _
	handle as FB_FILE ptr, _
	iPort as long, _
	options as FB_SERIAL_OPTIONS ptr, _
	pszDevice as ubyte ptr, _
	ppvHandle as any ptr ptr _
) as long
    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function

Function fb_SerialGetRemaining( handle as FB_FILE ptr, pvHandle as any ptr, pLength as fb_off_t ptr ) as long

    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function

Function fb_SerialWrite( handle as FB_FILE ptr, pvHandle as any ptr, data_ as const any ptr, length as size_t ) as long

    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function

Function fb_SerialRead( handle as FB_FILE ptr, pvHandle as any ptr, data_ as any ptr, pLength as size_t ptr ) as long

    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function

Function fb_SerialClose( handle as FB_FILE ptr, pvHandle as any ptr) as long

    return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function
End Extern
