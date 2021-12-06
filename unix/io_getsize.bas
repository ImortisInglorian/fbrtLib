#include "../fb.bi"
#include "fb_private_console.bi"

Extern "C"
Sub fb_ConsoleGetSize FBCALL( cols as long ptr, rows as long ptr)

	if( __fb_con.inited = 0) then
		if( cols <> Null ) then *cols = 80
		if( rows <> Null ) then *rows = 24
		Exit Sub
	end if

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	if( cols <> Null ) then *cols = __fb_con.w
	if( rows <> Null ) then *rows = __fb_con.h
End Sub
End Extern