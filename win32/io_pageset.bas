/' console 'screen , pg, pg' function '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_hConsoleCreateBuffer( ) as HANDLE
	dim as HANDLE hnd = CreateConsoleScreenBuffer( GENERIC_READ or GENERIC_WRITE, 0, NULL, CONSOLE_TEXTMODE_BUFFER, NULL )
	if ( hnd = NULL ) then
		return NULL
	end if

	/' size must be the stdout ones '/
	dim as CONSOLE_SCREEN_BUFFER_INFO csbi
	GetConsoleScreenBufferInfo( __fb_con.outHandle, @csbi )
	SetConsoleScreenBufferSize( hnd, csbi.dwSize )

	return hnd
end function

private sub hHideCursor( pg1 as long, pg2 as long )
	dim as CONSOLE_CURSOR_INFO cci

	GetConsoleCursorInfo( __fb_con.outHandle, @cci )
	cci.bVisible = FALSE

	SetConsoleCursorInfo( __fb_con.pgHandleTb(pg1), @cci )
	if ( pg2 >= 0 ) then
		SetConsoleCursorInfo( __fb_con.pgHandleTb(pg2), @cci )
	end if
end sub

function fb_ConsolePageSet ( active as long, visible as long ) as long
	fb_hConsoleGetHandle( FALSE )

	dim as long res = __fb_con.active or (__fb_con.visible shl 8)

	if ( active >= 0 ) then
		if ( __fb_con.pgHandleTb(active) = NULL ) then
            dim as HANDLE hnd = fb_hConsoleCreateBuffer( )
            if ( hnd = NULL ) then
            	return -1
			else
				__fb_con.pgHandleTb(active) = hnd
			end if
		end if

		/' if page isn't visible, hide the cursor '/
		if ( active <> __fb_con.visible ) then
			hHideCursor( active, -1 )
		end if

		__fb_con.active = active
	end if

	if ( visible >= 0 ) then
		if ( __fb_con.pgHandleTb(visible) = NULL ) then
            dim as HANDLE hnd = fb_hConsoleCreateBuffer( )
            if ( hnd = NULL ) then
            	return -1
			else
				__fb_con.pgHandleTb(visible) = hnd
			end if
		end if

		if ( __fb_con.visible <> visible ) then
            SetConsoleActiveScreenBuffer( __fb_con.pgHandleTb(visible) )

			/' if pages aren't the same, hide the cursor '/
			if ( visible <> __fb_con.active ) then
				hHideCursor( __fb_con.active, visible )
			end if

			__fb_con.visible = visible
		end if
	end if

	return res
end function
end extern