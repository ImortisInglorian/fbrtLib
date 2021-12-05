#include "../fb.bi"

Extern "c"
Function fb_ConsoleIsRedirected( is_input As Long ) As Long

	dim filenum as Long = fileno( Iif(is_input, stdin, stdout) )
	return Iif( isatty( filenum ) = 0, FB_TRUE, FB_FALSE )
End Function
End Extern