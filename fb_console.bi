#ifdef fb_ConsoleView
	#undef fb_ConsoleView
	#undef fb_ConsoleInput
	#undef fb_ConsolePrintBufferWstrEx
#endif

type fb_Rect
	as long Left, Top, Right, Bottom
end type

type fb_Coord
	as long X, Y
end type

type _fb_ConHooks as fb_ConHooks

type fb_fnHookConScroll as sub ( handle as _fb_ConHooks ptr, x1 as long, y1 as long, x2 as long, y2 as long, rows as long )
type fb_fnHookConWrite as function ( handle as _fb_ConHooks ptr, buffer as const any ptr, length as size_t ) as long

type fb_ConHooks
	as any ptr 				Opaque

	as fb_fnHookConScroll 	Scroll
	as fb_fnHookConWrite 	Write

	as fb_Rect 				Border
	as fb_Coord 			Coord
end type

extern "C"
private function fb_hConCheckScroll( handle as fb_ConHooks ptr ) as long
	dim as fb_Rect ptr pBorder = @handle->Border
	dim as fb_Coord ptr pCoord = @handle->Coord
	if ( pBorder->Bottom <> -1 ) then
		if ( pCoord->Y > pBorder->Bottom ) then
			dim as long nRows = pCoord->Y - pBorder->Bottom
			handle->Scroll( handle, pBorder->Left, pBorder->Top, pBorder->Right, pBorder->Bottom, nRows )
			return TRUE
		end if
	end if
	return FALSE
end function

declare sub 	 fb_ConPrintRaw      			( handle as fb_ConHooks ptr, pachText as const ubyte ptr, TextLength as size_t )
declare sub 	 fb_ConPrintRawWstr  			( handle as fb_ConHooks ptr, pachText as const FB_WCHAR ptr, TextLength as size_t )
declare sub 	 fb_ConPrintTTY      			( handle as fb_ConHooks ptr, pachText as const ubyte ptr, TextLength as size_t, is_text_mode as long )
declare sub 	 fb_ConPrintTTYWstr  			( handle as fb_ConHooks ptr, pachText as const FB_WCHAR ptr, TextLength as size_t, is_text_mode as long )

declare function fb_ConsoleWidth     			( cols as long, rows as long ) as long
declare sub 	 fb_ConsoleClear     			( mode as long )

declare function fb_ConsoleLocate    			( row as long, col as long, cursor as long ) as long
declare function fb_ConsoleGetY      			( ) as long
declare function fb_ConsoleGetX      			( ) as long
declare sub 	 fb_ConsoleGetSize 		 FBCALL ( cols as long ptr, rows as long ptr )
declare sub 	 fb_ConsoleGetXY   		 FBCALL ( col as long ptr, row as long ptr )

declare function fb_ConsoleReadXY 		 FBCALL ( col as long, row as long, colorflag as long ) as ulong
declare function fb_ConsoleColor     			( fc as ulong, bc as ulong, flags as long ) as ulong
declare function fb_ConsoleGetColorAtt			( ) as ulong

declare function fb_ConsoleView 		 FBCALL ( toprow as long, botrow as long ) as long
declare function fb_ConsoleViewEx    			( toprow as long, botrow as long, set_cursor as long ) as long
declare sub 	 fb_ConsoleGetView   			( toprow as long ptr, botrow as long ptr )
declare function fb_ConsoleGetMaxRow 			( ) as long
declare sub 	 fb_ConsoleViewUpdate			( )

declare sub 	 fb_ConsoleScroll    			( nrows as long )

declare function fb_ConsoleGetkey    			( ) as long
declare function fb_ConsoleInkey     			( ) as FBSTRING ptr
declare function fb_ConsoleKeyHit    			( ) as long

declare function fb_ConsoleMultikey  			( scancode as long ) as long
declare function fb_ConsoleGetMouse  			( x as long ptr, y as long ptr, z as long ptr, buttons_ as long ptr, clip as long ptr ) as long
declare function fb_ConsoleSetMouse  			( x as long, y as long, cursor as long, clip as long ) as long

declare sub 	 fb_ConsolePrintBuffer			( buffer as const ubyte ptr, mask as long )
declare sub 	 fb_ConsolePrintBufferWstr		( buffer as const FB_WCHAR ptr, mask as long )
declare sub 	 fb_ConsolePrintBufferEx		( buffer as const any ptr, _len as size_t, mask as long )
declare sub 	 fb_ConsolePrintBufferWstrEx	( buffer as const FB_WCHAR ptr, _len as size_t, mask as long )

declare function fb_ConsoleReadStr 				( buffer as ubyte ptr, _len as size_t ) as ubyte ptr

declare function fb_ConsoleGetTopRow 			( ) as long
declare function fb_ConsoleGetBotRow 			( ) as long
declare sub 	 fb_ConsoleSetTopBotRows		( top as long, bot as long )

declare sub 	 fb_ConsoleSleep 				( msecs as long )

declare function fb_ConsoleIsRedirected			( is_input as long ) as long

declare function fb_ConsolePageCopy 			( src as long, dst as long ) as long
declare function fb_ConsolePageSet 				( active as long, visible as long ) as long

declare function fb_ConReadLine 		 FBCALL ( soft_cursor as long ) as FBSTRING ptr

declare function fb_ConsoleInput 		 FBCALL ( text as FBSTRING ptr, addquestion as long, addnewline as long ) as long
declare function fb_ConsoleLineInput 			( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
declare function fb_ConsoleLineInputWstr		( text as const FB_WCHAR ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long

declare function fb_hConsoleInputBufferChanged  ( ) as long
end extern