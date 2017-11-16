/' console mode mouse functions '/

#include "../fb.bi"
#include "fb_private_console.bi"

dim shared as long inited = -1
dim shared as long last_x = 0, last_y = 0, last_z = 0, last_buttons = 0

extern "C"
sub ProcessMouseEvent(pEvent as MOUSE_EVENT_RECORD const ptr)
	if ( pEvent->dwEventFlags = MOUSE_WHEELED ) then
		last_z += ( iif(( pEvent->dwButtonState and &hFF000000 ), -1, 1 ))
	else
		last_x = pEvent->dwMousePosition.X
		last_y = pEvent->dwMousePosition.Y
		last_buttons = pEvent->dwButtonState and &h7
	end if
end sub

function fb_ConsoleGetMouse( x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr ) as long
	#if 0
	dim as INPUT_RECORD ir
	dim as DWORD dwRead
	#endif

	dim as DWORD dwMode

	if ( inited = -1 ) then
		inited = GetSystemMetrics( SM_CMOUSEBUTTONS )
		if ( inited ) then
			GetConsoleMode( __fb_in_handle, @dwMode )
			dwMode or= ENABLE_MOUSE_INPUT
			SetConsoleMode( __fb_in_handle, dwMode )
			#if 1
			__fb_con.mouseEventHook = cast(fb_FnProcessMouseEvent, @ProcessMouseEvent)
			#endif
			last_x = 1
			last_y = 1
			fb_hConvertToConsole( @last_x, @last_y, NULL, NULL )
		end if
	end if

	if ( inited = 0 ) then
		*x = -1
		*y = -1
		*z = -1
		*buttons = -1
		return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end if

	if ( inited > 0) then
		GetConsoleMode( __fb_in_handle, @dwMode )
		if ( not(dwMode and ENABLE_MOUSE_INPUT) ) then
			dwMode or= ENABLE_MOUSE_INPUT
			SetConsoleMode( __fb_in_handle, dwMode )
		end if
	end if

	#if 0
	if ( PeekConsoleInput( __fb_in_handle, @ir, 1, @dwRead ) ) then
		if( dwRead > 0 ) then
			ReadConsoleInput( __fb_in_handle, @ir, 1, @dwRead )
			if ( ir.EventType = MOUSE_EVENT ) then
				ProcessMouseEvent( @ir.Event.MouseEvent )
			end if
		end if
	end if
	#else
	fb_ConsoleProcessEvents( )
	#endif

	*x = last_x - 1
	*y = last_y - 1
	*z = last_z
	*buttons = last_buttons
	*clip = 0

	fb_hConvertFromConsole( x, y, NULL, NULL )

	return FB_RTERROR_OK
end function

function fb_ConsoleSetMouse( x as long, y as long, cursor as long, clip as long ) as long
	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
end function
end extern