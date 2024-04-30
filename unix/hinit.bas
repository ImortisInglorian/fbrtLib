/' libfb initialization for Unix '/

/' for getpgid() and PTHREAD_MUTEX_RECURSIVE '/
#define _GNU_SOURCE 1

#include "../fb.bi"
#include "fb_private_console.bi"
#include "unix_private_thread.bi"
#include "../crt_extra/signal.bi"
#include "termcap.bi"

#if defined HOST_LINUX AndAlso (defined HOST_X86 OrElse defined HOST_X86_64)
	/'
	The sys/ headers are architecture and OS dependent. They 
	do not exist across all targets and io.h in particular 
	is intended for very low-level non-portable uses often 
	in coordination with the kernel. The only targets that 
	provide sys/io.h are x86*, Alpha, IA64, and 32-bit ARM.
	No other systems provide it.
	From https://bugzilla.redhat.com/show_bug.cgi?id=1116162
	or http://www.hep.by/gnu/gnulib/ioperm.html#ioperm
	'/
	#include "sys/io.bi"
#endif

#include "sys/ioctl.bi"
#include "fcntl.bi"

Common Shared __fb_con as FBCONSOLE
static shared old_sighandler(NSIG) as SIGHANDLER
/' !!!FIXME!!! volatile required '/
static shared /' volatile '/ __fb_console_resized as sig_atomic_t
static shared seq(0 to 16) as const ubyte ptr = { _
	sadd("cm"), sadd("ho"), sadd("cs"), sadd("cl"), _
	sadd("ce"), sadd("WS"), sadd("bl"), sadd("AF"), _
	sadd("AB"), sadd("me"), sadd("md"), sadd("SF"), _
	sadd("ve"), sadd("vi"), sadd("dc"), sadd("ks"), _
	sadd("ke") _
}

static shared __fb_bg_thread as Any Ptr
static shared bgthread_inited as boolean = FALSE
static shared __fb_bg_mutex as pthread_mutex_t

Private Sub fb_BgLock FBCALL ( ) 
    pthread_mutex_lock ( @__fb_bg_mutex )
End Sub

Private Sub fb_BgUnlock FBCALL ( ) 
    pthread_mutex_unlock( @__fb_bg_mutex )
End Sub

#ifdef ENABLE_MT
Extern "C"
declare function pthread_mutexattr_settype(attr as pthread_mutexattr_t ptr, kind as long) as long
End Extern

static shared __fb_global_mutex as pthread_mutex_t
static shared __fb_string_mutex as pthread_mutex_t
static shared __fb_graphics_mutex as pthread_mutex_t
static shared __fb_math_mutex as pthread_mutex_t
static shared __fb_profile_mutex as pthread_mutex_t

Sub fb_Lock FBCALL ( ) pthread_mutex_lock  ( @__fb_global_mutex ) End Sub
Sub fb_Unlock FBCALL ( )  pthread_mutex_unlock( @__fb_global_mutex ) End Sub
Sub fb_StrLock FBCALL ( ) pthread_mutex_lock  ( @__fb_string_mutex ) End Sub
Sub fb_StrUnlock FBCALL ( ) pthread_mutex_unlock( @__fb_string_mutex ) End Sub
Sub fb_GraphicsLock FBCALL ( ) pthread_mutex_lock  ( @__fb_graphics_mutex ) End Sub
Sub fb_GraphicsUnlock FBCALL ( ) pthread_mutex_unlock( @__fb_graphics_mutex ) End Sub
Sub fb_MathLock FBCALL ( ) pthread_mutex_lock  ( @__fb_math_mutex ) End Sub
Sub fb_MathUnlock FBCALL ( ) pthread_mutex_unlock( @__fb_math_mutex ) End Sub
Sub fb_ProfileLock FBCALL ( ) pthread_mutex_lock  ( @__fb_profile_mutex ) End Sub
Sub fb_ProfileUnlock FBCALL ( ) pthread_mutex_unlock( @__fb_profile_mutex ) End Sub
#endif

Sub bg_thread(arg as Any Ptr)

	while (__fb_con.inited <> 0) 

		BG_LOCK()
		if (__fb_con.keyboard_handler <> Null ) then
			__fb_con.keyboard_handler()
		end if
		if (__fb_con.mouse_handler <> Null ) then
			__fb_con.mouse_handler()
		end if
		BG_UNLOCK()

		usleep(30000)
	Wend
End Sub

Sub fb_hStartBgThread( )

	if( bgthread_inited = FALSE ) then
		__fb_bg_thread = ThreadCreate(bg_thread)
		bgthread_inited = TRUE
	end if
End Sub

Private Function default_getch() as long

	return fgetc(__fb_con.f_in)
End Function

Private Sub signal_handler(sig as long)

	signal(sig, old_sighandler(sig))
	fb_hEnd(1)
	raise(sig)
End Sub

#ifdef HOST_LINUX
/' Query window size or cursor position from the terminal by sending the
   respective escape sequence to stdout and reading the answer (report) from
   stdin.
   That's assuming that the terminal actually supports the escape sequence and
   sends a response. If it does not, we'll hang forever (or at least until the
   read from stdin returns EOF).
   Used with SEQ_QUERY_WINDOW and SEQ_QUERY_CURSOR only (but could easily be
   extended to support more). '/
Function fb_hTermQuery( code as long, val1 as long ptr, val2 as long ptr) as long

	if( fb_hTermOut( code, 0, 0 ) = FALSE ) then
		return FALSE
	end if

	dim filled as long
	do
		/' The terminal should have sent its reply through stdin. However, it's
		   possible that there's other data pending in stdin, e.g. if the user
		   happened to press a key at the right time. '/

		/' Read until an '\e[' (ESC char followed by '[') is reached,
		   it should be the begin of the terminal's answer string) '/
		dim c as long
		do
			do
				c = getchar( )
				if( c = EOF ) then return FALSE
				if( c = asc(!"\&h1b") ) then exit do

				/' Add skipped char to Inkey() buffer so it's not lost '/
				fb_hAddCh( c )
			while True

			c = getchar( )
			if( c = asc("[") ) then exit do

			/' ditto '/
			fb_hAddCh( c )
		while true

		dim format as const ubyte ptr
		if( code = SEQ_QUERY_WINDOW ) then
			format = sadd("8;%d;%dt")
		else /' SEQ_QUERY_CURSOR '/
			format = sadd("%d;%dR")
		end if

		filled = scanf( format, val1, val2 )
	while (filled <> 2)

	return TRUE
End Function
#endif

/'*
 * Update our cursor position with information from the terminal, if possible,
 * to make it more accurate. (It's possible that the cursor moved outside of
 * our control; e.g. if the FB program did a printf() instead of using FB's
 * PRINT)
 '/
Sub fb_hRecheckCursorPos( )

#ifdef HOST_LINUX
	dim as long x, y
	if( fb_hTermQuery( SEQ_QUERY_CURSOR, @y, @x ) ) then
		__fb_con.cur_x = x
		__fb_con.cur_y = y
	end if
#endif
End Sub

/'*
 * Check whether the SIGWINCH handler has been called, and if so, re-query
 * the terminal width/height.
 *  - Assuming BG_LOCK() is acquired, because this can be called from
 *    linux/io_mouse.c:mouse_handler() from the background thread
 *  - Assuming __fb_con.inited
 *
 *  The "requery_cursorpos" parameter allows callers to disable the cursor
 *  position update we'd normally do too in this case. This is useful if the
 *  caller wants to do it manually, regardless of whether SIGWINCH happened,
 *  while at the same time avoiding duplicate queries.
 '/
Sub fb_hRecheckConsoleSize( requery_cursorpos as long )

	if( __fb_console_resized = FALSE ) then
		Exit Sub
	end if

	/' __fb_console_resized may be set to TRUE again here if a SIGWINCH
	   arrives while we're doing this check.

	   If it happens here before we're setting __fb_console_resized to FALSE
	   then it doesn't matter, because we're about to check the console size
	   anyways.

	   If it happens later (during/after the check below) then we'll miss
	   it this time; but at least the next fb_hRecheckConsoleSize() will
	   handle it. '/

	__fb_console_resized = FALSE

	/' Try to query the terminal size '/
	/' Try TIOCGWINSZ '/
	dim win as winsize
	if( ioctl( STDOUT_FILENO, TIOCGWINSZ, @win ) <> 0 ) then
#ifdef HOST_LINUX
		/' Try an escape sequence '/
		dim as long r, c
		if( fb_hTermQuery( SEQ_QUERY_WINDOW, @r, @c ) ) then
			win.ws_row = r
			win.ws_col = c
		end if
#endif
	end if

	/' Fallback to defaults if all above queries failed '/
	/' Besides probably being correct, this also means we don't have to
	   handle the case of unknown terminal size all over the rtlib code.
	   For example, fb_ConReadLine() assumes that fb_GetSize() returns
	   non-zero rows/columns. '/
	if( win.ws_row = 0 OrElse win.ws_col = 0 ) then
		win.ws_row = 25
		win.ws_col = 80
	end if

	dim char_buffer as ubyte ptr = CAllocate(1, win.ws_row * win.ws_col * 2)
	dim attr_buffer as ubyte ptr = char_buffer + (win.ws_row * win.ws_col)
	if (__fb_con.char_buffer) then
		dim h as long = Iif(__fb_con.h < win.ws_row, __fb_con.h, win.ws_row)
		dim w as long = Iif(__fb_con.w < win.ws_col, __fb_con.w. win.ws_col)
		for r As long = 0 to h - 1
			memcpy(char_buffer + (r * win.ws_col), __fb_con.char_buffer + (r * __fb_con.w), w)
			memcpy(attr_buffer + (r * win.ws_col), __fb_con.attr_buffer + (r * __fb_con.w), w)
		Next
		DeAllocate(__fb_con.char_buffer)
	end if
	__fb_con.char_buffer = char_buffer
	__fb_con.attr_buffer = attr_buffer
	__fb_con.h = win.ws_row
	__fb_con.w = win.ws_col

	/' Also update the cursor position if wanted '/
	if (requery_cursorpos) then
		fb_hRecheckCursorPos( )
	end if

	fb_DevScrnMaybeUpdateWidth( )
End Sub

Private Sub sigwinch_handler(sig as long)

	__fb_console_resized = TRUE
	signal(SIGWINCH, sigwinch_handler)
End Sub

Function fb_hTermOut( code as long, param1 as long, param2 as long ) as long

	/' Hard-coded VT100 terminal escape sequences corresponding to our SEQ_*
	   #defines with values >= 100. Apparently these codes are not available
	   through termcap/terminfo (tgetstr()), so we need to hard-code them.

	   These cannot safely be used for some (old) terminals which don't
	   support them, as the terminal won't recognize them, thus won't send
	   a response, leaving us hanging and waiting for a response. We don't
	   have a good way of preventing this issue though especially since we
	   can't rely on termcap/terminfo for this.

	   Thus, we provide the __fb_enable_vt100_escapes global variable, which
	   FB programs can set to TRUE or FALSE as needed at runtime. '/
	dim extra_seq(0 to 6) as const ubyte ptr = { sadd(!"\&h1b(U"), sadd(!"\&h1b(B"), sadd(!"\&h1b[6n"), sadd(!"\&h1b[18t"), _
		sadd(!"\&h1b[?1000h\&h1b[?1003h"), sadd(!"\&h1b[?1003l\&h1b[?1000l"), sadd(!"\&h1b[H\&h1b[J\&h1b[0m") }

	dim str as ubyte ptr

	if (__fb_con.inited = False) then return FALSE

	if (code > SEQ_MAX) then

		/' Is use of the VT100 escape sequences disallowed? '/
		if ( __fb_enable_vt100_escapes = False ) then
			return FALSE
		end if

		if(code = SEQ_SET_COLOR_EX) then
			if( fprintf( stdout, "\&h1b[%dm", param1 ) < 4 ) then
				return FALSE
			end if
		elseif( fputs( extra_seq(code - SEQ_EXTRA), stdout ) = EOF ) then
				return FALSE
		end if

	else
		if (__fb_con.seq[code] = False) then
			return FALSE
		end if
		str = tgoto(__fb_con.seq(code), param1, param2)
		if (str = Null) then
			return FALSE
		end if
		tputs(str, 1, putchar)
	end if

	/' Ensure the terminal gets to see the escape sequence '/
	fflush( stdout )

	return TRUE
End Function

Function fb_hInitConsole() as Long

	dim term_out as termios
	dim term_in as termios

	if (__fb_con.inited = False) then
		return -1
	end if

	/' Init terminal I/O '/
	if( !isatty( STDOUT_FILENO ) OrElse !isatty( STDIN_FILENO ) ) then
		return -1
	end if
	__fb_con.f_in = fopen("/dev/tty", "r+b")
	if (__fb_con.f_in = NULL) then
		return -1
	end if
	__fb_con.h_in = fileno(__fb_con.f_in)
	
	/' Cannot control console if process was started in background '/
	if( tcgetpgrp( STDOUT_FILENO ) <> getpgid( 0 ) ) then
		return -1
	end if

	/' Output setup '/
	if( tcgetattr( STDOUT_FILENO, @__fb_con.old_term_out ) ) then
		return -1
	end if
	memcpy(@term_out, @__fb_con.old_term_out, sizeof(term_out))
	term_out.c_oflag Or= OPOST
	if( tcsetattr( STDOUT_FILENO, TCSANOW, @term_out ) ) then
		return -1
	end if

	/' Input setup '/
	if (tcgetattr(__fb_con.h_in, @__fb_con.old_term_in)) then
		return -1
	end if
	memcpy(@term_in, @__fb_con.old_term_in, sizeof(term_in))
	/' Send SIGINT on control-C '/
	term_in.c_iflag Or= BRKINT
	/' Disable Xon/off and input BREAK condition ignoring '/
	term_in.c_iflag And= Not(IXOFF Or IXON Or IGNBRK)
	/' Character oriented, no echo '/
	term_in.c_lflag And= Not(ICANON Or ECHO)
	/' No timeout, just don't block '/
	term_in.c_cc[VMIN] = 1
	term_in.c_cc[VTIME] = 0
	if (tcsetattr(__fb_con.h_in, TCSANOW, @term_in)) then
		return -1
	end if

	/' Don't block '/
	__fb_con.old_in_flags = fcntl(__fb_con.h_in, F_GETFL, 0)
	fcntl(__fb_con.h_in, F_SETFL, __fb_con.old_in_flags Or O_NONBLOCK)

#ifdef HOST_LINUX
	if (__fb_con.inited = INIT_CONSOLE) then
		fb_hTermOut(SEQ_INIT_CHARSET, 0, 0)
	end if
#endif
	fb_hTermOut(SEQ_INIT_KEYPAD, 0, 0)

	/' Initialize keyboard and mouse handlers if set '/
	BG_LOCK()
	if (__fb_con.keyboard_init <> Null) then __fb_con.keyboard_init()
	if (__fb_con.mouse_init <> Null) then __fb_con.mouse_init()
	BG_UNLOCK()

	return 0
End Function

Sub fb_hExitConsole( )

	dim bottom as long
	dim old_sigttou_handler as SIGHANDLER

	if (__fb_con.inited) then

		/' Ignore SIGTTOU, which is sent in case we write to the
		   terminal while being in the background (e.g. CTRL+Z + bg).
		   This happens at least with the tcsetattr() on STDOUT_FILENO
		   for restoring the original terminal state below, because we
		   switched to non-canonical mode in fb_hInitConsole (~ICANON).

		   The default handler for SIGTTOU suspends the process,
		   but we don't want to hang now when exiting the FB program.

		   We probably shouldn't ignore SIGTTOU (or SIGTTIN for that
		   matter) globally/always though, as normally the behaviour
		   makes sense: If a background program tries to write to the
		   terminal (or read user input), it should be suspended until
		   brought to foreground by the user. Otherwise it would
		   interfere with whatever the user is currently doing.

		   However, implicit terminal adjustments done by the rtlib is a
		   case where we probably don't want that to happen. Thus the
		   signal should be ignored only here. '/
		old_sigttou_handler = signal(SIGTTOU, SIG_IGN)

		if (__fb_con.gfx_exit) then
			__fb_con.gfx_exit()
		end if
		
		BG_LOCK()
		if (__fb_con.keyboard_exit) then
			__fb_con.keyboard_exit()
		end if
		if (__fb_con.mouse_exit) then
			__fb_con.mouse_exit()
		end if
		BG_UNLOCK()

		/' Only restore scrolling region if we changed it. This way we can avoid
		   calling fb_ConsoleGetMaxRow(), which may have to query the terminal size.
		   It's best to avoid that as much as possible (not all terminals support
		   the escape sequence, it's slow, it's unsafe if fb_hExitConsole() is called
		   during a signal handler). '/
		if (__fb_con.scroll_region_changed) then
			bottom = fb_ConsoleGetMaxRow()
			if ((fb_ConsoleGetTopRow() <> 0) OrElse (fb_ConsoleGetBotRow() <> bottom - 1)) then
				/' Restore scrolling region to whole screen and clear '/
				fb_hTermOut(SEQ_SCROLL_REGION, bottom - 1, 0)
				fb_hTermOut(SEQ_CLS, 0, 0)
				fb_hTermOut(SEQ_HOME, 0, 0)
			end if
			__fb_con.scroll_region_changed = FALSE
		end if

		/' Cleanup terminal '/
#ifdef HOST_LINUX
		if (__fb_con.inited = INIT_CONSOLE) then
			fb_hTermOut(SEQ_EXIT_CHARSET, 0, 0)
		end if
#endif
		fb_hTermOut(SEQ_RESET_COLOR, 0, 0)
		fb_hTermOut(SEQ_SHOW_CURSOR, 0, 0)
		fb_hTermOut(SEQ_EXIT_KEYPAD, 0, 0)
		tcsetattr( STDOUT_FILENO, TCSANOW, @__fb_con.old_term_out )

		/' Restore old console keyboard state '/
		fcntl(__fb_con.h_in, F_SETFL, __fb_con.old_in_flags)
		tcsetattr(__fb_con.h_in, TCSANOW, @__fb_con.old_term_in)

		if (__fb_con.f_in) then
			fclose(__fb_con.f_in)
			__fb_con.f_in = NULL
		end if

		/' Restore SIGTTOU handler (so it's no longer ignored) '/
		signal(SIGTTOU, old_sigttou_handler)
	end if
End Sub

Private Sub hInit( )

	dim sigs(0 to 7) as Long = { SIGABRT, SIGFPE, SIGILL, SIGSEGV, SIGTERM, SIGINT, SIGQUIT, -1 }
	dim buffer(0 to 2047) as ubyte
	dim as ubyte ptr p, term
	dim tty as termios
	dim attr as pthread_mutexattr_t
	dim i as long

#ifdef HOST_X86
	dim control_word as ulong

	/' Get FPU control word '/
	asm fstcw [control_word]
	/' Set 64-bit and round to nearest '/
	control_word = (control_word and &HF0FF) or &H0300
	/' Write back FPU control word '/
	asm fldcw [FPUControlWord]
#endif

	/' make mutex recursive to behave the same on Win32 and Linux (if possible) '/
	pthread_mutexattr_init(@attr)
	pthread_mutexattr_settype(@attr, PTHREAD_MUTEX_RECURSIVE)

#ifdef ENABLE_MT
	/' Init multithreading support '/
	pthread_mutex_init(@__fb_global_mutex, @attr)
	pthread_mutex_init(@__fb_string_mutex, @attr)
	pthread_mutex_init(@__fb_graphics_mutex, @attr)
	pthread_mutex_init(@__fb_math_mutex, @attr)
	pthread_mutex_init(@__fb_profile_mutex, @attr)
#endif

	pthread_mutex_init(@__fb_bg_mutex, @attr)

	memset(@__fb_con, 0, sizeof(__fb_con));

	/' Init termcap '/
	term = getenv("TERM")
	if ((term = Null) OrElse (tgetent(buffer, term) <= 0)) then
		Exit Sub
	end if
	BC = 0 : UP = 0
	p = tgetstr("pc", NULL)
	PC = Iif(p <> Null, *p, 0)
	if (tcgetattr(1, @tty)) then
		Exit Sub
	end if
	ospeed = cfgetospeed(@tty)
	if (!tgetflag("am")) then
		Exit Sub
	end if
	for i = 0 to SEQ_MAX - 1
		__fb_con.seq(i) = tgetstr(seq(i), NULL)
	next

	/' !!!TODO!!! detect other OS consoles? (freebsd: 'cons25', etc?) '/
	if ((strcmp(term, "console") = 0) OrElse (strncmp(term, "linux", 5) = 0)) then
		__fb_con.inited = INIT_CONSOLE
	else
		__fb_con.inited = INIT_X11
	end if

	if (strncasecmp(term, "eterm", 5) = 0) then
		__fb_con.term_type = TERM_ETERM
	elseif (strncmp(term, "xterm", 5) = 0) then
		__fb_con.term_type = TERM_XTERM
	else
		__fb_con.term_type = TERM_GENERIC
	end if

	if (fb_hInitConsole()) then
		__fb_con.inited = 0
		Exit Sub
	end if
	__fb_con.keyboard_getch = default_getch

	/' Install signal handlers to quietly shut down '/
	i = 0
	while sigs(i) >= 0 
		dim sig as long = sigs(i)
		old_sighandler(sig) = signal(sig,  signal_handler)
		i += 1
	wend

	__fb_con.char_buffer = NULL
	__fb_con.fg_color = 7
	__fb_con.bg_color = 0

	/' Trigger console window size & cursor position checks the first time
	   fb_hRecheckConsoleSize() is invoked (lazy initialization).

	   It's good to do this lazily because we don't need this information
	   until the first use of one of FB's console I/O commands anyways.
	   For FB programs which don't use those we never have to bother
	   retrieving this information from the terminal.

	   This is also good because we may try to use some special terminal
	   escape sequences which the terminal may not support, in which case
	   we end up hanging, waiting for an answer forever (fb_hTermOut() and
	   fb_hTermQuery()). In that case, at least, we'll only hang when the
	   FB program uses console I/O commands, but not always on start up of
	   every FB program. '/
	__fb_console_resized = TRUE

	/' In case it's not possible to retrieve the real cursor position from
	   the terminal, we assume to start out at 1,1. '/
	__fb_con.cur_y = 1 : __fb_con.cur_x = 1

	signal(SIGWINCH, sigwinch_handler)
End Sub

Sub fb_hInit( )

	hInit( )

#if defined HOST_LINUX AndAlso (defined HOST_X86 OrElse defined HOST_X86_64)
	/' Permissions for port I/O '/
	__fb_con.has_perm = Iif(ioperm(0, &H400, 1), FALSE, TRUE)
#endif
End Sub

Sub fb_hEnd( unused as long )

	fb_hExitConsole()
	__fb_con.inited = 0
	if( bgthread_inited ) then
		pthread_join(__fb_bg_thread, NULL)
		bgthread_inited = FALSE
	end if
	pthread_mutex_destroy(@__fb_bg_mutex)

	if (__fb_con.char_buffer) then
		DeAllocate(__fb_con.char_buffer)
		__fb_con.char_buffer = NULL
		__fb_con.attr_buffer = NULL
	end if

#ifdef ENABLE_MT
	/' Release multithreading support resources '/
	pthread_mutex_destroy(@__fb_global_mutex)
	pthread_mutex_destroy(@__fb_string_mutex)
	pthread_mutex_destroy(@__fb_graphics_mutex)
	pthread_mutex_destroy(@__fb_math_mutex)
	pthread_mutex_destroy(@__fb_profile_mutex)
#endif
End Sub
