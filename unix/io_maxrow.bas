#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleGetMaxRow( ) As Long

	if( __fb_con.inited = 0 ) then return 24

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )
	return __fb_con.h
End Function
End Extern
