/' low-level print to console function '/

#include "../fb.bi"
#include "fb_private_console.bi"

type fb_PrintInfo
	as fb_Rect         rWindow
	as fb_Coord        BufferSize
	as WORD            wAttributes
	as HANDLE          hOutput
	as long            fViewSet
end type

extern "C"
private sub fb_hHookConScroll ( handle as fb_ConHooks ptr, x1 as long, y1 as long, x2 as long, y2 as long, rows as long )
	dim as fb_PrintInfo ptr pInfo = cast(fb_PrintInfo ptr, handle->Opaque)
	dim as HANDLE hnd = pInfo->hOutput
	dim as long iBufferHeight, iScrollHeight, iClearFrom, iClearTo, iClearPos

	dim as SMALL_RECT srScroll
	dim as COORD dwDest

	if ( pInfo->fViewSet = NULL ) then
		/' Try to move the window first ... '/
		if ( (handle->Border.Bottom + 1) < pInfo->BufferSize.Y ) then
			dim as long remaining = pInfo->BufferSize.Y - handle->Border.Bottom - 1
			dim as long move_size = iif((remaining < rows), remaining, rows)

			handle->Border.Top += move_size
			handle->Border.Bottom += move_size

			rows -= move_size
			if ( rows = 0 ) then
				exit sub
			end if
		end if

		/' We're at the end of the screen buffer - so we have to
		 * scroll the complete screen buffer '/
		dwDest.X = dwDest.Y = 0
		srScroll.Right = cast(SHORT, (pInfo->BufferSize.X-1))
		srScroll.Bottom = cast(SHORT, (pInfo->BufferSize.Y-1))
		iBufferHeight = pInfo->BufferSize.Y

	else
		/' Scroll only the area defined by a previous VIEW PRINT '/
		dwDest.X = cast(SHORT, handle->Border.Left)
		dwDest.Y = cast(SHORT, handle->Border.Top)
		srScroll.Right = cast(SHORT, handle->Border.Right)
		srScroll.Bottom = cast(SHORT, handle->Border.Bottom)
		iBufferHeight = handle->Border.Bottom - handle->Border.Top + 1
	end if

	if ( iBufferHeight <= rows ) then
		/' simply clear the buffer '/
		iClearFrom = handle->Border.Top
		iClearTo = handle->Border.Bottom + 1
	else
		/' Move some part of the console screen buffer to another
		 * position. '/
		dim as CHAR_INFO FillChar

		srScroll.Left = dwDest.X
		srScroll.Top = cast(SHORT, (dwDest.Y + rows))

		iScrollHeight = srScroll.Bottom - srScroll.Top + 1
		if ( iScrollHeight < rows ) then
			/' Don't forget that we have to clear some screen buffer regions
			 * not covered by the original scrolling region '/
			iClearFrom = dwDest.Y + iScrollHeight
			iClearTo = srScroll.Bottom + 1
		else
			iClearFrom = iClearTo = 0
		end if

		FillChar.Attributes = pInfo->wAttributes
		FillChar.Char.UnicodeChar = 32

		ScrollConsoleScreenBufferW( hnd, @srScroll, NULL, dwDest, @FillChar )
	end if

	/' Clear all parts of the screen buffer not covered by the scrolling
	* region '/
	if ( iClearFrom <> iClearTo ) then
		dim as SHORT x1 = handle->Border.Left
		dim as WORD attr = pInfo->wAttributes
		dim as DWORD wid = handle->Border.Right - x1 + 1
		for iClearPos = iClearFrom to iClearTo - 1
			dim as DWORD written
			dim as COORD coord = ( x1, cast(SHORT, iClearPos) )
			FillConsoleOutputAttribute( hnd, attr, wid, coord, @written)
			FillConsoleOutputCharacterW( hnd, 32, wid, coord, @written )
		next
	end if

	handle->Coord.Y = handle->Border.Bottom
end sub

private function fb_hHookConWrite( handle as fb_ConHooks ptr, buffer as const any ptr, length as size_t ) as long
	dim as fb_PrintInfo ptr pInfo = cast(fb_PrintInfo ptr, handle->Opaque)
	dim as HANDLE hnd = pInfo->hOutput
	dim as const FB_WCHAR ptr pachText = cast(const FB_WCHAR ptr, buffer)
	dim as CHAR_INFO ptr lpBuffer = malloc( sizeof(CHAR_INFO) * length )
	dim as WORD wAttributes = pInfo->wAttributes
	dim as COORD dwBufferSize = ( cast(SHORT, length), 1 )
	dim as COORD dwBufferCoord = ( 0, 0 )
	dim as SMALL_RECT srWriteRegion = ( cast(SHORT, handle->Coord.X), cast(SHORT, handle->Coord.Y), cast(SHORT, (handle->Coord.X + length - 1)), cast(SHORT, handle->Coord.Y) )
	dim as size_t i
	dim as long result

	for i = 0 to length - 1
		dim as CHAR_INFO ptr pCharInfo = lpBuffer + i
		pCharInfo->Attributes = wAttributes
		pCharInfo->Char.UnicodeChar = pachText[i]
	next

	result = WriteConsoleOutputW( hnd, lpBuffer, dwBufferSize, dwBufferCoord, @srWriteRegion )
	return result
end function

sub fb_ConsolePrintBufferWstrEx( buffer as const FB_WCHAR ptr, chars as size_t, mask as long )
	dim as const FB_WCHAR ptr pachText = cast(const FB_WCHAR ptr, buffer)
	dim as long win_left, win_top, win_cols, win_rows
	dim as long view_top, view_bottom
	dim as fb_PrintInfo info
	dim as fb_ConHooks hooks

	/' Do we want to correct the console cursor position? '/
	if ( (mask and FB_PRINT_FORCE_ADJUST) = 0 ) then
		/' No, we can check for the length to avoid unnecessary stuff ... '/
		if ( chars = 0 ) then
			exit sub
		end if
	end if

	FB_LOCK()

	/' is the output redirected? '/
	if ( FB_CONSOLE_WINDOW_EMPTY() <> NULL ) then
		dim as DWORD dwBytesWritten, bytes = chars * sizeof( FB_WCHAR )

		while( bytes <> 0 )
			if ( WriteFile( __fb_out_handle, pachText, bytes, @dwBytesWritten, NULL ) <> TRUE ) then
				exit while
			end if

			pachText += dwBytesWritten
			bytes -= dwBytesWritten
		wend

		FB_UNLOCK()
		exit sub
	end if

	fb_ConsoleGetView( @view_top, @view_bottom )
	fb_hConsoleGetWindow( @win_left, @win_top, @win_cols, @win_rows )

	hooks.Opaque        = @info
	hooks.Scroll        = cast(fb_fnHookConScroll, @fb_hHookConScroll)
	hooks.Write         = cast(fb_fnHookConWrite, @fb_hHookConWrite)
	hooks.Border.Left   = win_left
	hooks.Border.Top    = win_top + view_top - 1
	hooks.Border.Right  = win_left + win_cols - 1
	hooks.Border.Bottom = win_top + view_bottom - 1

	info.hOutput        = __fb_out_handle
	info.rWindow.Left   = win_left
	info.rWindow.Top    = win_top
	info.rWindow.Right  = win_left + win_cols - 1
	info.rWindow.Bottom = win_top + win_rows - 1
	info.fViewSet       = hooks.Border.Top <> info.rWindow.Top or hooks.Border.Bottom <> info.rWindow.Bottom

	scope
		dim as CONSOLE_SCREEN_BUFFER_INFO screen_info

		if ( GetConsoleScreenBufferInfo( __fb_out_handle, @screen_info ) = NULL ) then
			hooks.Coord.X = hooks.Border.Left
			hooks.Coord.Y = hooks.Border.Top
			info.BufferSize.X = FB_SCRN_DEFAULT_WIDTH
			info.BufferSize.Y = FB_SCRN_DEFAULT_HEIGHT
			info.wAttributes = 7
		else
			hooks.Coord.X = screen_info.dwCursorPosition.X
			hooks.Coord.Y = screen_info.dwCursorPosition.Y
			info.BufferSize.X = screen_info.dwSize.X
			info.BufferSize.Y = screen_info.dwSize.Y
			info.wAttributes = screen_info.wAttributes
		end if

		if ( __fb_con.scrollWasOff <> NULL ) then
			__fb_con.scrollWasOff = FALSE
			hooks.Coord.Y += 1
			hooks.Coord.X = hooks.Border.Left
			fb_hConCheckScroll( @hooks )
		end if

		fb_ConPrintTTYWstr( @hooks, pachText, chars, TRUE )

		if ( hooks.Coord.X <> hooks.Border.Left or hooks.Coord.Y <> (hooks.Border.Bottom + 1) ) then
			fb_hConCheckScroll( @hooks )
		else
			__fb_con.scrollWasOff = TRUE
			hooks.Coord.X = hooks.Border.Right
			hooks.Coord.Y = hooks.Border.Bottom
		end if

		scope
			dim as COORD dwCoord = type( cast(SHORT, hooks.Coord.X), cast(SHORT, hooks.Coord.Y) )
			SetConsoleCursorPosition( info.hOutput, dwCoord )
		end scope
	end scope

	if ( hooks.Border.Top <> win_top and not(info.fViewSet) ) then
		/' Now we have to ensure that the window shows the right part
		 * of the screen buffer when it was moved previously ... '/
		dim as SMALL_RECT srWindow = ( cast(SHORT, hooks.Border.Left), cast(SHORT, hooks.Border.Top), cast(SHORT, hooks.Border.Right), cast(SHORT, hooks.Border.Bottom) )
		SetConsoleWindowInfo( info.hOutput, TRUE, @srWindow )
	end if

	fb_hUpdateConsoleWindow( )

	FB_UNLOCK()
end sub

sub fb_ConsolePrintBufferWstr( buffer as const FB_WCHAR ptr, mask as long )
	fb_ConsolePrintBufferWstrEx( buffer, fb_wstr_Len( buffer ), mask )
end sub
end extern 