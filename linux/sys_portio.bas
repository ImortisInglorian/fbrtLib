/' ports I/O functions '/

#include "../fb.bi"
#include "../unix/fb_private_console.bi"

Extern "c"
Function fb_hIn( port as ushort ) as long

#if defined (HOST_LINUX) andalso (defined(HOST_X86) orelse defined(HOST_X86_64))
	dim value as ubyte
	if (__fb_con.has_perm = False) then
		return -fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
	end if
	Asm
		mov dx, port
		in AL, DX
		mov byte ptr[value], AL
	End Asm
	return value
#else
	return -fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
#endif
End Function

Function fb_hOut( port as ushort, value as ubyte ) as long

#if defined (HOST_LINUX) andalso (defined(HOST_X86) orelse defined(HOST_X86_64))
	if (__fb_con.has_perm = False) then
		return fb_ErrorSetNum( FB_RTERROR_NOPRIVILEGES )
	end if
	Asm
		mov DX, value
		mov AX, port
		out DX, AX
	End Asm
	return FB_RTERROR_OK
#else
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
#endif
End Function
End Extern

