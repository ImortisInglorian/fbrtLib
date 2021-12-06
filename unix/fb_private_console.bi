#define INIT_CONSOLE 1
#define INIT_X11     2

#define TERM_GENERIC 0
#define TERM_XTERM   1
#define TERM_ETERM   2

#define SEQ_LOCATE        0   /' "cm" - move cursor '/
#define SEQ_HOME          1   /' "ho" - home cursor '/
#define SEQ_SCROLL_REGION 2   /' "cs" - set scrolling region '/
#define SEQ_CLS           3   /' "cl" - clear whole screen '/
#define SEQ_CLEOL         4   /' "ce" - clear until end of line '/
#define SEQ_WINDOW_SIZE   5   /' "WS" - set terminal window size '/
#define SEQ_BEEP          6   /' "bl" - beep '/
#define SEQ_FG_COLOR      7   /' "AF" - set foreground color '/
#define SEQ_BG_COLOR      8   /' "AB" - set background color '/
#define SEQ_RESET_COLOR   9   /' "me" - turn off all attributes '/
#define SEQ_BRIGHT_COLOR  10  /' "md" - turn on bold (bright) attribute '/
#define SEQ_SCROLL        11  /' "SF" - scroll forward '/
#define SEQ_SHOW_CURSOR   12  /' "ve" - make cursor visible '/
#define SEQ_HIDE_CURSOR   13  /' "vi" - make cursor invisible '/
#define SEQ_DEL_CHAR      14  /' "dc" - delete character at cursor position '/
#define SEQ_INIT_KEYPAD   15  /' "ks" - enable keypad keys '/
#define SEQ_EXIT_KEYPAD   16  /' "ke" - disable keypad keys '/
#define SEQ_MAX           17
#define SEQ_EXTRA         100
#ifdef HOST_LINUX
	#define SEQ_INIT_CHARSET  100  /' xxxx - inits PC 437 characters set '/
	#define SEQ_EXIT_CHARSET  101  /' xxxx - exits PC 437 characters set '/
	#define SEQ_QUERY_CURSOR  102  /' xxxx - query cursor position (not in termcap) '/
	#define SEQ_QUERY_WINDOW  103  /' xxxx - query terminal window size (not in termcap) '/
	#define SEQ_INIT_XMOUSE   104  /' xxxx - enable X11 mouse '/
	#define SEQ_EXIT_XMOUSE   105  /' xxxx - disable X11 mouse '/
	#define SEQ_EXIT_GFX_MODE 106  /' xxxx - cleanup after console gfx mode '/
#endif
#define SEQ_SET_COLOR_EX  107  /' xxxx - extended set color '/

Type FBCONSOLE

	as long inited
	as long term_type
	as long h_in
	as FILE ptr f_in
	as termios old_term_out, old_term_in
	as long old_in_flags
	as long fg_color, bg_color
	as long cur_x, cur_y
	as long w, h
	as ubyte ptr char_buffer, attr_buffer
#if defined (HOST_LINUX) andalso (defined(HOST_X86) orelse defined(HOST_X86_64))
	as long has_perm
#endif
	as long scroll_region_changed
	as ubyte ptr seq(SEQ_MAX)
	as function () as long keyboard_getch
	as function () as long keyboard_init
	as sub () keyboard_exit
	as sub () keyboard_handler
	as function () as long mouse_init
	as sub () mouse_exit
	as sub () mouse_handler
	as sub (cb as long, cx as long, cy as long) mouse_update
	as sub () gfx_exit
End Type

extern __fb_con as FBCONSOLE

#ifdef HOST_LINUX
Declare Function fb_hTermQuery( code as long, val1 as long ptr, val2 as long ptr ) as long
#endif
Declare Sub fb_hRecheckCursorPos( )
Declare Sub fb_hRecheckConsoleSize( requery_cursorpos as long )
Declare Function fb_hTermOut( code as long, param1 as long, param2 as long ) as long
Declare Sub fb_hAddCh( k as long )
Declare Function fb_hGetCh( remove as long ) as long
Declare Function fb_hXTermInitFocus( ) as long 
Declare Sub fb_hXTermExitFocus( )
Declare Function fb_hXTermHasFocus( ) as long
Declare Function fb_hConsoleGfxMode _
	( _
		gfx_exit as Sub( ), _
		save as Sub( ), _
		restore as Sub( ), _
		key_handler as Sub( as long, as long, as long, as long ) _
	) as long
Declare Function fb_hInitConsole( ) as long
Declare Sub fb_hExitConsole( )
Declare Sub fb_hStartBgThread(  )
