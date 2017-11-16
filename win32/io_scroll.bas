/' console scrolling for when VIEW is used '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
private sub fb_ConsoleScrollRawEx( hConsole as HANDLE, x1 as long, y1 as long, x2 as long, y2 as long, nrows as long )
	dim as long height = y2 - y1 + 1

	if ( nrows <= 0 ) then
		exit sub
	end if

	if ( nrows >= height ) then
		/' clear view '/
		fb_ConsoleClearViewRawEx( hConsole, x1, y1, x2, y2 )
	else
		/' scroll view '/
		dim as SMALL_RECT srec
		dim as COORD dcoord
		dim as CHAR_INFO cinf

		srec.Left 	= cast(SHORT, x1)
		srec.Right 	= cast(SHORT, x2)
		srec.Top 	= cast(SHORT, (y1 + nrows))
		srec.Bottom = cast(SHORT, y2)

		dcoord.X = cast(SHORT, x1)
		dcoord.Y = cast(SHORT, y1)

		cinf.Char.AsciiChar	= 32
		cinf.Attributes 	= fb_ConsoleGetColorAttEx( hConsole )

		ScrollConsoleScreenBuffer( hConsole, @srec, NULL, dcoord, @cinf )
		#if 0
		fb_ConsoleLocateRawEx( hConsole, y2 - nrows, -1, -1 )
		#endif
	end if
end sub

sub fb_ConsoleScroll( nrows as long )
	dim as long _left, _right
	dim as long toprow, botrow

	if ( nrows <= 0 ) then
		exit sub
	end if

	_left = 1
	fb_ConsoleGetSize( @_right, NULL )
	fb_ConsoleGetView( @toprow, @botrow )
	fb_hConvertToConsole( @_left, @toprow, @_right, @botrow )

	fb_ConsoleScrollRawEx( __fb_out_handle, _left, toprow, _right, botrow, nrows )
end sub
end extern