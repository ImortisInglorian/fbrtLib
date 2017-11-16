/' console window stuff '/

#include "../fb.bi"
#include "fb_private_console.bi"

dim shared as SMALL_RECT srRealConsoleWindow

extern "C"
private sub hReadConsoleRect( pRect as SMALL_RECT ptr, GetRealWindow as long )
	dim as CONSOLE_SCREEN_BUFFER_INFO info

	if ( GetConsoleScreenBufferInfo( __fb_out_handle, @info ) = 0 ) then
		memset( pRect, 0, sizeof(SMALL_RECT) )
	else
		if ( GetRealWindow ) then
			memcpy( pRect, @info.srWindow, sizeof(SMALL_RECT) )
		else
			pRect->Left = 0
			pRect->Top = info.srWindow.Top
			pRect->Right = info.dwSize.X - 1
			pRect->Bottom = info.srWindow.Bottom
		end if
	end if
end sub

/'' Remembers the current console window coordinates.
 *
 * This function remembers the current console window coordinates. This is
 * required because some applications showing using a SAA interface doesn't
 * use WIDTH first to reduce the console screen buffer size which means that
 * the scroll bar of the console window is always visible/accessible which
 * also implies that the user might scroll up and down while the application
 * is running.
 *
 * When this library would always use the current console window coordinates,
 * the application might show trash when the user scrolled up or down the
 * buffer. But this is not what we want so we're only updating the console
 * window coordinates under the following conditions:
 *
 * - Initialization
 * - After screen buffer size change (using WIDTH)
 * - After printing text
 '/

sub fb_hUpdateConsoleWindow FBCALL ( )
	/' Whenever the console was set by the user, we MUST NOT query this
	 * information again because this would cause a mess with SAA
	 * applications otherwise. '/
	if (__fb_con.setByUser) then
		exit sub
	end if

	hReadConsoleRect( @__fb_con.window, FALSE )
	hReadConsoleRect( @srRealConsoleWindow, TRUE )
end sub

sub fb_InitConsoleWindow( )
	static as long inited = FALSE
	if ( not(inited) ) then
		inited = TRUE
		/' query the console window position/size only when needed '/
		fb_hUpdateConsoleWindow( )
	end if
end sub

sub fb_hRestoreConsoleWindow FBCALL ( )
	dim as SMALL_RECT sr

	/' Whenever the console was set by the user, there's no need to
	 * restore the original window console because we don't have to
	 * mess around with scrollable windows '/
	if (__fb_con.setByUser) then
		exit sub
	end if

	fb_InitConsoleWindow( )

	/' Update only when changed! '/
	hReadConsoleRect( @sr, TRUE )
	if ( (sr.Top <> srRealConsoleWindow.Top) or (sr.Bottom <> srRealConsoleWindow.Bottom) ) then
		/' Keep the left/right coordinate of the console '/
		sr.Top = srRealConsoleWindow.Top
		sr.Bottom = srRealConsoleWindow.Bottom
		dim as long i
		for i = 0 to FB_CONSOLE_MAXPAGES
			if ( __fb_con.pgHandleTb(i) <> NULL ) then
				SetConsoleWindowInfo( __fb_con.pgHandleTb(i), TRUE, @srRealConsoleWindow )
			end if
		next
	end if
end sub

sub fb_ConsoleGetMaxWindowSize( cols as long ptr, rows as long ptr )
	dim as COORD _max_ = GetLargestConsoleWindowSize( __fb_out_handle )
	if ( cols <> NULL ) then
		*cols = iif(_max_.X = 0, FB_SCRN_DEFAULT_WIDTH, _max_.X)
	end if
	if ( rows <> NULL ) then
		*rows = iif(_max_.Y = 0, FB_SCRN_DEFAULT_HEIGHT, _max_.Y)
	end if
end sub

sub fb_hConvertToConsole FBCALL ( _left as long ptr, top as long ptr, _right as long ptr, bottom as long ptr )
	dim as long win_left, win_top

	fb_InitConsoleWindow()

	if ( FB_CONSOLE_WINDOW_EMPTY() ) then
		exit sub
	end if

	fb_hConsoleGetWindow( @win_left, @win_top, NULL, NULL )

	if ( _left <> NULL ) then
		*_left += win_left - 1
	end if
	if ( top <> NULL ) then
		*top += win_top - 1
	end if
	if ( _right <> NULL ) then
		*_right += win_left - 1
	end if
	if ( bottom <> NULL ) then
		*bottom += win_top - 1
	end if
end sub

sub fb_hConvertFromConsole FBCALL ( _left as long ptr, top as long ptr, _right as long ptr, bottom as long ptr )
	dim as long win_left, win_top

	fb_InitConsoleWindow()

	if ( FB_CONSOLE_WINDOW_EMPTY() ) then
		exit sub
	end if

	fb_hConsoleGetWindow( @win_left, @win_top, NULL, NULL )

	if ( _left <> NULL ) then
		*_left -= win_left - 1
	end if
	if ( top <> NULL ) then
		*top -= win_top - 1
	end if
	if ( _right <> NULL ) then
		*_right -= win_left - 1
	end if
	if ( bottom <> NULL ) then
		*bottom -= win_top - 1
	end if
end sub

sub fb_hConsoleGetWindow( _left as long ptr, top as long ptr, cols as long ptr, rows as long ptr )
	fb_InitConsoleWindow( )

	if ( FB_CONSOLE_WINDOW_EMPTY() ) then
		if ( _left <> NULL ) then
			*_left = 0
		end if
		if ( top <> NULL ) then
			*top = 0
		end if
		if ( cols <> NULL ) then
			*cols = 0
		end if
		if ( rows <> NULL ) then
			*rows = 0
		end if
	else
		if ( _left <> NULL ) then
			*_left = __fb_con.window.Left
		end if
		if ( top <> NULL ) then
			*top = __fb_con.window.Top
		end if
		if ( cols <> NULL ) then
			*cols = __fb_con.window.Right - __fb_con.window.Left + 1
		end if
		if ( rows <> NULL ) then
			*rows = __fb_con.window.Bottom - __fb_con.window.Top + 1
		end if
	end if
end sub
end extern