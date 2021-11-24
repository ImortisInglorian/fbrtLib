/' console width() for Windows '/
/' code based on PDCurses, Win32 port by Chris Szurgot (szurgot@itribe.net) '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleWidth( cols as long, rows as long ) as long
	dim as COORD size, _max_
	dim as long cur, do_change = FALSE
	dim as long ncols, nrows

	fb_InitConsoleWindow( )

	if ( FB_CONSOLE_WINDOW_EMPTY() <> NULL ) then
		return 0
	end if

	_max_ = GetLargestConsoleWindowSize( __fb_out_handle )
	fb_hConsoleGetWindow( NULL, NULL, @ncols, @nrows )

	if ( cols > 0 ) then
		size.X = cols
		do_change = TRUE
	else
		size.X = cast(SHORT, ncols)
	end if

	if ( rows > 0 ) then
		size.Y = rows
		do_change = TRUE
	else
		size.Y = cast(SHORT, nrows)
	end if

	cur = size.X or (size.Y shl 16)

	if ( do_change = FALSE ) then
		return cur
	end if

	dim as SMALL_RECT rect
	rect.Left = rect.Top = 0
	rect.Right = size.X - 1
	if ( rect.Right > _max_.X ) then
		rect.Right = _max_.X
	end if

	rect.Bottom = rect.Top + size.Y - 1
	if ( rect.Bottom > _max_.Y ) then
		rect.Bottom = _max_.Y
	end if

	/' Ensure that the window isn't larger than the destination screen
	* buffer size '/
	dim as long do_resize = FALSE
	dim as SMALL_RECT rectRes
	if ( rect.Bottom < (nrows-1) ) then
		do_resize = TRUE
		memcpy( @rectRes, @rect, sizeof(SMALL_RECT) )
		if ( rectRes.Right >= ncols ) then
			rectRes.Right = ncols - 1
		end if
	elseif ( rect.Right < (ncols-1) ) then
		do_resize = TRUE
		memcpy( @rectRes, @rect, sizeof(SMALL_RECT) )
		if ( rectRes.Bottom >= nrows ) then
			rectRes.Bottom = nrows - 1
		end if
	end if

	if ( do_resize <> NULL ) then
		dim as long i
		for i = 0 to FB_CONSOLE_MAXPAGES - 1
			if ( __fb_con.pgHandleTb(i) <> NULL ) then
				SetConsoleWindowInfo( __fb_con.pgHandleTb(i), TRUE, @rectRes )
			end if
		next
	end if

	/' Now set the screen buffer size and ensure that the window is
	* large enough to show the whole buffer '/
	dim as long i
	for i = 0 to FB_CONSOLE_MAXPAGES - 1
		if ( __fb_con.pgHandleTb(i) <> NULL ) then
			SetConsoleScreenBufferSize( __fb_con.pgHandleTb(i), size )
			SetConsoleWindowInfo( __fb_con.pgHandleTb(i), TRUE, @rect )
		end if
	next

	/' Re-enable updating '/
	__fb_con.setByUser = FALSE
	fb_hUpdateConsoleWindow( )
	__fb_con.setByUser = TRUE

	return cur
end function
end extern