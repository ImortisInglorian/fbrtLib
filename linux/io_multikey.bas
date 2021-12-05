/' Linux multikey function implementation '/

#include "../fb.bi"
#include "../unix/fb_private_console.bi"
#include "sys/ioctl.bi"
#include "signal.bi"
#include "linux/kd.bi"
#include "linux/keyboard.bi"
#include "linux/vt.bi"

#define KEY_BUFFER_SIZE		16
#define NUM_PAD_KEYS		17

Declare Function keyboard_init() as long
Declare Sub keyboard_exit()

#ifndef DISABLE_X11
#include "../fb_private_hdynload.bi"
#include "../unix/fb_private_scancodes_x11.bi"

Type X_FUNCS
    as XOPENDISPLAY OpenDisplay
    as XCLOSEDISPLAY CloseDisplay
    as XQUERYKEYMAP QueryKeymap
    as XDISPLAYKEYCODES DisplayKeycodes
    as XGETKEYBOARDMAPPING GetKeyboardMapping
    as XFREE Free
End Type

static shared display_ as Display ptr
static shared xlib as FB_DYLIB = NULL
static shared X as X_FUNCS = { NULL, NULL, NULL, NULL, NULL, NULL }
#endif

static shared main_pid as pid_t
static shared key_fd, key_old_mode, key_leds as long
static shared key_state(0 to 127) as ubyte
static shared key_buffer(0 to KEY_BUFFER_SIZE - 1) as ushort
static shared key_head, key_tail as ushort
static shared old_getch as Function() as long
static shared gfx_save as Sub()
static shared gfx_restore as Sub()
static shared gfx_key_handler as Sub(a as long, b as long, c as long, d as long)

static shared pad_numlock_ascii as Const ZString Ptr = sadd(!"0123456789+-'/\r,.")
static shared pad_ascii(0 to NUM_PAD_KEYS - 1) as const ubyte = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, asc("+"), asc("-"), asc("*"), asc("/"), asc(!"\r"), 0, 0 }

static shared kernel_to_scancode(0 to 127) as const ubyte = { _
	0,				SC_ESCAPE,		SC_1,			SC_2, _
	SC_3,			SC_4,			SC_5,			SC_6, _
	SC_7,			SC_8,			SC_9,			SC_0, _
	SC_MINUS,		SC_EQUALS,		SC_BACKSPACE,	SC_TAB, _ 
	SC_Q,			SC_W,			SC_E,			SC_R, _
	SC_T,			SC_Y,			SC_U,			SC_I, _
	SC_O,			SC_P,			SC_LEFTBRACKET,	SC_RIGHTBRACKET, _
	SC_ENTER,		SC_CONTROL,		SC_A,			SC_S, _
	SC_D,			SC_F,			SC_G,			SC_H, _
	SC_J,			SC_K,			SC_L,			SC_SEMICOLON, _
	SC_QUOTE,		SC_TILDE,		SC_LSHIFT,		SC_BACKSLASH, _
	SC_Z,			SC_X,			SC_C,			SC_V, _
	SC_B,			SC_N,			SC_M,			SC_COMMA, _
	SC_PERIOD,		SC_SLASH,		SC_RSHIFT,		SC_MULTIPLY, _
	SC_ALT,			SC_SPACE,		SC_CAPSLOCK,	SC_F1, _
	SC_F2,			SC_F3,			SC_F4,			SC_F5, _
	SC_F6,			SC_F7,			SC_F8,			SC_F9, _
	SC_F10,			SC_NUMLOCK,		SC_SCROLLLOCK,	SC_HOME, _
	SC_UP,			SC_PAGEUP,		SC_MINUS,		SC_LEFT, _
	SC_CLEAR,		SC_RIGHT,		SC_PLUS,		SC_END, _
	SC_DOWN,		SC_PAGEDOWN,	SC_0,			SC_DELETE, _
	0,				0,				SC_BACKSLASH,	SC_F11, _
	SC_F12,			0,				0,				0, _
	0,				0,				0,				0, _
	SC_ENTER,		SC_CONTROL,		SC_SLASH,		0, _
	SC_ALTGR,		0,				SC_HOME,		SC_UP, _
	SC_PAGEUP,		SC_LEFT,		SC_RIGHT,		SC_END, _
	SC_DOWN,		SC_PAGEDOWN,	SC_INSERT,		SC_DELETE, _
	0,				0,				0,				0, _
	0,				0,				0,				0, _
	0,				0,				0,				0, _
	0,				SC_LWIN,		SC_RWIN,		SC_MENU _
}

Private Function keyboard_console_getch() as long

	dim key as long = -1

	BG_LOCK()

	if (key_head <> key_tail) then
		key = key_buffer(key_head)
		key_head = (key_head + 1) And (KEY_BUFFER_SIZE - 1)
	end if

	BG_UNLOCK()

	return key
End Function

Private Sub keyboard_console_handler()

	dim buffer(0 to 127) as ubyte
	dim buffer_ptr as ubyte ptr = @buffer(0)
	dim key_state_ptr as ubyte ptr = @key_state(0)
	dim scancode as ubyte
	dim as long pressed, repeated, num_bytes, i, key, extended
	dim as long vt, orig_vt
	dim entry as kbentry
	dim vt_state as vt_stat

	num_bytes = read(key_fd, buffer_ptr, sizeof(buffer))
	if (num_bytes > 0) then
		for i = 0 to num_bytes - 1
			scancode = kernel_to_scancode(buffer_ptr[i] And &h7F)
			pressed = (buffer_ptr[i] And &h80) Xor &h80
			repeated = pressed AndAlso key_state_ptr[scancode]
			key_state_ptr[scancode] = pressed

			/' Since we took over keyboard control, we have to map our keypresses to ascii
			 * in order to report them in our own keyboard buffer '/

			extended = 0
			select case scancode
			case SC_CAPSLOCK   if (pressed) then key_leds Xor= LED_CAP
			case SC_NUMLOCK    if (pressed) then key_leds Xor= LED_NUM
			case SC_SCROLLLOCK if (pressed) then key_leds Xor= LED_SCR
			case else extended = fb_hScancodeToExtendedKey( scancode )
			end select

			/' Fill in kbentry struct for KDGKBENT query '/
			entry.kb_table = 0 /' modifier table '/
			if (key_state_ptr[SC_LSHIFT] OrElse key_state_ptr[SC_RSHIFT]) then entry.kb_table Or= &h1
			if (key_state_ptr[SC_ALTGR]) then entry.kb_table Or= &h2
			if (key_state_ptr[SC_CONTROL]) then	entry.kb_table Or= &h4
			if (key_state_ptr[SC_ALT]) then entry.kb_table Or= &h8
			entry.kb_index = scancode /' keycode '/
			ioctl(key_fd, KDGKBENT, @entry)

			if (scancode = SC_BACKSPACE) then key = 8
			elseif (entry.kb_value = K_NOSUCHMAP) then key = 0
			else
				key = KVAL(entry.kb_value)
				select case KTYP(entry.kb_value)
					case KT_LETTER
						if (key_leds And LED_CAP) then key Xor= &h20
					case KT_LATIN, KT_ASCII:
						'' Do nothing
					case KT_PAD
						if (key < NUM_PAD_KEYS) then
							if (key_leds And LED_NUM) then
								key = pad_numlock_ascii[key]
							else
								key = pad_ascii(key)
							end if
						else
							key = 0
						end if
					case KT_SPEC
						if (scancode = SC_ENTER) then key = asc(!"\r")
					case KT_CONS
						vt = key + 1
						if( pressed AndAlso (ioctl(key_fd, VT_GETSTATE, @vt_state) >= 0) ) then
							orig_vt = vt_state.v_active
							if (vt <> orig_vt) then
								if (__fb_con.gfx_exit) then
									gfx_save()
									ioctl(key_fd, KDSETMODE, KD_TEXT)
								end if
								ioctl(key_fd, VT_ACTIVATE, vt)
								ioctl(key_fd, VT_WAITACTIVE, vt)
								while (ioctl(key_fd, VT_WAITACTIVE, orig_vt) < 0)
								    usleep(50000)
								wend
								if (__fb_con.gfx_exit) then
									ioctl(key_fd, KDSETMODE, KD_GRAPHICS)
									gfx_restore()
								end if
								memset(key_state, FALSE, 128)
							else
								key_state_ptr[scancode] = FALSE
							end if
							extended = 0
						end if
						key = 0
					case else
						key = 0
				end select
			end if

			if( extended ) then key = extended

			if( pressed AndAlso key ) then
				key_buffer(key_tail) = key
				if (((key_tail + 1) And (KEY_BUFFER_SIZE - 1)) = key_head) then
					key_head = (key_head + 1) And (KEY_BUFFER_SIZE - 1)
				key_tail = (key_tail + 1) And (KEY_BUFFER_SIZE - 1)
			end if

			if( gfx_key_handler ) then
				gfx_key_handler( pressed, repeated, scancode, key )
			end if
		next
	end if

	/' CTRL + C '/
	if( key_state_ptr[SC_CONTROL] AndAlso key_state_ptr[SC_C] ) then
		kill(main_pid, SIGINT)
	end if
End Sub

#ifndef DISABLE_X11
Private Sub keyboard_x11_handler()

	dim keymap(0 to 31) as ubyte
	dim key_state_ptr as ubyte ptr = @key_state(0)
	dim i as long

	if (fb_hXTermHasFocus() = 0) then
		Exit Sub
	end if
	X.QueryKeymap(display_, keymap)
	memset(@key_state(0), FALSE, 128)
	for i = 0 to 255
		if (keymap[i / 8] And (1 Shl (i And &h7))) then
			key_state_ptr[fb_x11keycode_to_scancode(i)] = TRUE
		end if
	next
End Sub
#endif

Private Function keyboard_init() as long

#ifndef DISABLE_X11
	dim funcs(0 to 7) as const ubyte ptr = { _
		sadd("XOpenDisplay"), sadd("XCloseDisplay"), sadd("XQueryKeymap"), _
		sadd("XDisplayKeycodes"), sadd("XGetKeyboardMapping"), sadd("XFree"), NULL _
	}
#endif
	dim term as termios
	memset( @term, 0, sizeof( term ) )

	main_pid = getpid()
	old_getch = __fb_con.keyboard_getch

	if(__fb_con.inited = INIT_CONSOLE) then
		key_fd = dup(__fb_con.h_in)

		term.c_iflag = 0
		term.c_cflag = CS8
		term.c_lflag = 0
		term.c_cc(VMIN) = 0
		term.c_cc(VTIME) = 0

		if ((ioctl(key_fd, KDGKBMODE, @key_old_mode) < 0) OrElse _
		    (tcsetattr(key_fd, TCSANOW, @term) < 0) OrElse _
		    (ioctl(key_fd, KDSKBMODE, K_MEDIUMRAW) < 0)) {
			close(key_fd)
			return -1
		end if
		__fb_con.keyboard_handler = keyboard_console_handler
		__fb_con.keyboard_getch = keyboard_console_getch
		key_head = 0 : key_tail = 0
		ioctl(key_fd, KDGETLED, @key_leds)

#ifndef DISABLE_X11
	else
		xlib = fb_hDynLoad("libX11.so", funcs, cast(any ptr ptr, @X))
		if (xlib = Null) then return -1

		display_ = X.OpenDisplay(NULL)
		if (display_ = Null) then return -1

		fb_hInitX11KeycodeToScancodeTb( display_, X.DisplayKeycodes, X.GetKeyboardMapping, X.Free )

		fb_hXTermInitFocus()
		__fb_con.keyboard_handler = keyboard_x11_handler
#endif
	end if

	__fb_con.keyboard_init = keyboard_init
	__fb_con.keyboard_exit = keyboard_exit

	return 0
End Function

Private Sub keyboard_exit()

	if (__fb_con.inited = INIT_CONSOLE) then
		ioctl(key_fd, KDSKBMODE, key_old_mode)
		close(key_fd)
		key_fd = -1
	
#ifndef DISABLE_X11
	elseif (__fb_con.inited = INIT_X11) then
		X.CloseDisplay(display_)
		fb_hDynUnload(@xlib)
		fb_hXTermExitFocus()
#endif
	end if
	__fb_con.keyboard_getch = old_getch
	__fb_con.keyboard_handler = NULL
	__fb_con.keyboard_exit = NULL
End Sub

Extern "c"
Function fb_ConsoleMultikey(scancode as long) as long

	dim res as long

	if (__fb_con.inited = 0) then return FB_FALSE

	BG_LOCK()

	fb_hStartBgThread( )

	if ((__fb_con.keyboard_handler = Null) AndAlso (keyboard_init() = 0)) then
		/' Let the handler execute at least once to fill in states '/
		BG_UNLOCK()
		usleep(50000)
		BG_LOCK()
	end if

	res = Iif(key_state(scancode And &h7F), FB_TRUE, FB_FALSE)

	BG_UNLOCK()

	return res
End Function

Function fb_hConsoleGfxMode
( _
	gfx_exit as Sub(), _
	save as Sub(), _
	restore as Sub(), _
	key_handler as Sub(a as long, b as long, c as long, d as long) _
) as long

	BG_LOCK()

	fb_hStartBgThread( )

	__fb_con.gfx_exit = gfx_exit
	if (gfx_exit) then
		FB_LOCK( )
		__fb_ctx.hooks.multikeyproc = NULL
		__fb_ctx.hooks.inkeyproc = NULL
		__fb_ctx.hooks.getkeyproc = NULL
		__fb_ctx.hooks.keyhitproc = NULL
		__fb_ctx.hooks.sleepproc = NULL
		FB_UNLOCK( )
		gfx_save = save
		gfx_restore = restore
		gfx_key_handler = key_handler
		if (keyboard_init()) then
			BG_UNLOCK()
			return -1
		end if
		ioctl(key_fd, KDSETMODE, KD_GRAPHICS)
	else
		if (key_fd >= 0) then
			ioctl(key_fd, KDSETMODE, KD_TEXT)
			keyboard_exit()
			fb_hTermOut(SEQ_EXIT_GFX_MODE, 0, 0)
		end if
	end if

	BG_UNLOCK()

	return 0
End Function
End Extern