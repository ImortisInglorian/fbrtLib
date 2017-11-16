#ifdef fb_Color
	#undef fb_Color
	#undef fb_Width
	#undef fb_WidthDev
	#undef fb_WidthFile
	#undef fb_ReadXY
	#undef fb_LineInput
	#undef fb_LineInputWstr
	#undef fb_PageSet
#endif


extern "C"
type FB_INKEYPROC as function ( ) as FBSTRING ptr
type FB_GETKEYPROC as function ( ) as long
type FB_KEYHITPROC as function ( ) as long

declare function fb_Inkey           FBCALL ( ) as FBSTRING ptr
declare function fb_InkeyQB         FBCALL ( ) as FBSTRING ptr
declare function fb_Getkey          FBCALL ( ) as long
declare function fb_KeyHit          FBCALL ( ) as long

type FB_CLSPROC as sub ( mode as long )

declare sub 	  fb_Cls					FBCALL ( mode as long )

type FB_COLORPROC as function ( fc as long, bc as long, flags as long ) as long

declare function fb_Color				FBCALL ( fc as long, bc as long, flags as long ) as long

type FB_LOCATEPROC as function ( row as long, col as long, cursor as long ) as long

declare function fb_LocateEx 			FBCALL ( row as long, col as long, cursor as long, current_pos as long ptr ) as long
declare function fb_Locate 			FBCALL ( row as long, col as long, cursor as long, start as long, stop as long ) as long
declare function fb_LocateSub 		FBCALL ( row as long, col as long, cursor as long ) as long

type FB_VIEWUPDATEPROC as sub( )

declare sub 	  fb_ViewUpdate 		FBCALL ( )

type FB_WIDTHPROC as function ( cols as long, rows as long ) as long

declare function fb_Width 				FBCALL ( cols as long, rows as long ) as long
declare function fb_WidthDev 			FBCALL ( dev as FBSTRING ptr, width as long ) as long
declare function fb_WidthFile 		FBCALL ( fnum as long, width as long ) as long

type FB_GETXPROC as function ( ) as long
type FB_GETYPROC as function ( ) as long
type FB_GETXYPROC as sub ( col as long ptr, row as long ptr )
type FB_GETSIZEPROC as sub ( cols as long ptr, rows as long ptr )

declare function fb_Pos 				FBCALL ( dummy as long ) as long
declare function fb_GetX 				FBCALL ( ) as long
declare function fb_GetY 				FBCALL ( ) as long
declare sub 	  fb_GetXY 				FBCALL ( col as long ptr, row as long ptr )
declare sub 	  fb_GetSize 			FBCALL ( cols as long ptr, rows as long ptr )

type FB_READXYPROC as function ( col as long, row as long, colorflag as long ) as ulong
declare function fb_ReadXY 			FBCALL ( col as long, row as long, colorflag as long ) as ulong

type FB_PRINTBUFFPROC as sub ( buffer as any const ptr, len as size_t, mask as long )
type FB_PRINTBUFFWPROC as sub ( buffer as FB_WCHAR ptr, len as size_t, mask as long )

type FB_READSTRPROC as function ( buffer as ubyte ptr, len as ssize_t ) as ubyte ptr
declare function fb_ReadString 		cdecl  ( buffer as ubyte ptr, len as ssize_t, f as FILE ptr ) as ubyte ptr

type FB_LINEINPUTPROC as function ( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
type FB_LINEINPUTWPROC as function ( text as FB_WCHAR const ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long
declare function fb_LineInput 		FBCALL ( text as FBSTRING ptr, dst as any ptr, dst_len as ssize_t, fillrem as long, addquestion as long, addnewline as long ) as long
declare function fb_LineInputWstr 	FBCALL ( text as FB_WCHAR const ptr, dst as FB_WCHAR ptr, max_chars as ssize_t, addquestion as long, addnewline as long ) as long

declare function fb_Multikey 			FBCALL ( scancode as long ) as long
declare function fb_GetMouse 			FBCALL ( x as long ptr, y as long ptr, z as long ptr, buttons_ as long ptr, clip as long ptr ) as long
declare function fb_GetMouse64 		FBCALL ( x as longint ptr, y as longint ptr, z as longint ptr, buttons_ as longint ptr, clip as longint ptr ) as long
declare function fb_SetMouse 			FBCALL ( x as long, y as long, cursor as long, clip as long ) as long
type FB_MULTIKEYPROC as function ( scancode as long ) as long
type FB_GETMOUSEPROC as function ( x as long ptr, y as long ptr, z as long ptr, buttons_ as long ptr, clip as long ptr ) as long
type FB_SETMOUSEPROC as function ( x as long, y as long, cursor as long, clip as long ) as long

declare function fb_In 					FBCALL ( port as ushort ) as long
declare function fb_Out 				FBCALL ( port as ushort, value as ubyte ) as long
type FB_INPROC as function ( port as ushort ) as long
type FB_OUTPROC as function ( port as ushort, value as ubyte ) as long

declare sub 	  fb_Sleep 				FBCALL ( msecs as long )
declare sub 	  fb_SleepQB 			FBCALL ( secs as long )
declare sub 	  fb_Delay 				FBCALL ( msecs as long )
declare function fb_SleepEx 			FBCALL ( msecs as long, kind as long ) as long
type FB_SLEEPPROC as sub ( msecs as long )

declare function fb_IsRedirected 	FBCALL ( is_input as long ) as long
type FB_ISREDIRPROC as function ( is_input as long ) as long

declare function fb_PageCopy 			FBCALL ( src as long, dst as long ) as long
type FB_PAGECOPYPROC as function ( src as long, dst as long ) as long

declare function fb_PageSet 			FBCALL ( active as long, visible as long ) as long
type FB_PAGESETPROC as function ( active as long, visible as long ) as long

type FB_HOOKSTB
	as FB_INKEYPROC    		inkeyproc
	as FB_GETKEYPROC   		getkeyproc
	as FB_KEYHITPROC   		keyhitproc
	as FB_CLSPROC      		clsproc
	as FB_COLORPROC    		colorproc
	as FB_LOCATEPROC   		locateproc
	as FB_WIDTHPROC    		widthproc
	as FB_GETXPROC     		getxproc
	as FB_GETYPROC     		getyproc
	as FB_GETXYPROC    		getxyproc
	as FB_GETSIZEPROC  		getsizeproc
	as FB_PRINTBUFFPROC 	printbuffproc
	as FB_PRINTBUFFWPROC 	printbuffwproc
	as FB_READSTRPROC  		readstrproc
	as FB_MULTIKEYPROC 		multikeyproc
	as FB_GETMOUSEPROC 		getmouseproc
	as FB_SETMOUSEPROC 		setmouseproc
	as FB_INPROC       		inproc
	as FB_OUTPROC      		outproc
	as FB_VIEWUPDATEPROC 	viewupdateproc
	as FB_LINEINPUTPROC 	lineinputproc
	as FB_LINEINPUTWPROC 	lineinputwproc
	as FB_READXYPROC   		readxyproc
	as FB_SLEEPPROC    		sleepproc
	as FB_ISREDIRPROC		isredirproc
	as FB_PAGECOPYPROC		pagecopyproc
	as FB_PAGESETPROC		pagesetproc
end type
end extern