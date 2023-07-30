#include "windows.bi"

type fb_FnProcessMouseEvent as sub ( pEvent as const MOUSE_EVENT_RECORD ptr )

type FB_CONSOLE_CTX
	as HANDLE 			inHandle, outHandle
	as HANDLE 			pgHandleTb(0 to FB_CONSOLE_MAXPAGES - 1)
	as long				active, visible
	as SMALL_RECT 		window
	as long 			setByUser
	as long 			scrollWasOff
	as fb_FnProcessMouseEvent mouseEventHook
end type

extern as FB_CONSOLE_CTX __fb_con

extern "C"
declare function fb_hConsoleTranslateKey 			   ( AsciiChar as ubyte, wVsCode as WORD, wVkCode as WORD, dwControlKeyState as DWORD, bEnhancedKeysOnly as long ) as long
declare function fb_hVirtualToScancode 				   ( vkey as long ) as long
declare sub 	 fb_InitConsoleWindow 				   ( )
declare sub 	 fb_hRestoreConsoleWindow 		FBCALL ( )
declare sub 	 fb_hUpdateConsoleWindow 		FBCALL ( )
declare sub 	 fb_hConvertToConsole 			FBCALL ( _left as long ptr, top as long ptr, _right as long ptr, bottom as long ptr )
declare sub 	 fb_hConvertFromConsole 		FBCALL ( _left as long ptr, top as long ptr, _right as long ptr, bottom as long ptr )
declare sub 	 fb_ConsoleLocateRaw 			FBCALL ( row as long, col as long, cursor as long )
declare sub 	 fb_ConsoleGetScreenSize 		FBCALL ( cols as long ptr, rows as long ptr )
declare sub 	 fb_ConsoleGetMaxWindowSize 		   ( cols as long ptr, rows as long ptr )
declare sub 	 fb_ConsoleGetScreenSizeEx 			   ( hConsole as HANDLE, cols as long ptr, rows as long ptr )
declare function fb_ConsoleGetRawYEx 				   ( hConsole as HANDLE ) as long
declare function fb_ConsoleGetRawXEx 				   ( hConsole as HANDLE ) as long
declare sub 	 fb_ConsoleGetRawXYEx 				   ( hConsole as HANDLE, col as long ptr, row as long ptr )
declare sub 	 fb_ConsoleLocateRawEx 			   	   ( hConsole as HANDLE, row as long, col as long, cursor as long )
declare function fb_ConsoleGetColorAttEx 			   ( hConsole as HANDLE ) as ulong
declare sub 	 fb_ConsoleClearViewRawEx 		 	   ( hConsole as HANDLE, x1 as long, y1 as long, x2 as long, y2 as long )
declare sub 	 fb_hConsoleGetWindow 				   ( _left as long ptr, top as long ptr, cols as long ptr, rows as long ptr )
declare function fb_ConsoleProcessEvents 			   ( ) as long
declare function fb_hConsoleGetKey 					   ( full as long ) as long
declare function fb_hConsolePeekKey 				   ( full as long ) as long
declare sub 	 fb_hConsolePutBackEvents 			   ( )
declare function fb_hConsoleGetHandle 				   ( is_input as long ) as HANDLE
declare sub 	 fb_hConsoleResetHandles 			   ( )
declare function fb_ConsoleGetRawX 					   ( ) as long
declare function fb_ConsoleGetRawY 					   ( ) as long
declare function fb_hConsoleCreateBuffer 			   ( ) as HANDLE
end extern

#define __fb_in_handle  fb_hConsoleGetHandle( TRUE )
#define __fb_out_handle fb_hConsoleGetHandle( FALSE )

#macro FB_CON_CORRECT_POSITION()
	if ( __fb_con.scrollWasOff <> NULL ) then
		fb_ConsolePrintBufferEx( NULL, 0, FB_PRINT_FORCE_ADJUST )
	end if
#endmacro

#macro FB_CONSOLE_WINDOW_EMPTY()
	((__fb_con.window.Left = __fb_con.window.Right) orelse (__fb_con.window.Top = __fb_con.window.Bottom))
#endmacro