#ifndef __FB_BI__
	#define __FB_BI__

	/' Must be included before any system headers due to certain #defines '/
	#include "fb_config.bi"

	/' Minimum headers needed for fb.h alone, more in system-specific sections
	   below. These can be relied upon and don't need to be #included again. '/
	#include "crt.bi"

	#define FB_TRUE (-1)
	#define FB_FALSE 0

	#ifndef FALSE
		#define FALSE 0
	#endif

	#ifndef TRUE
		#define TRUE 1
	#endif
	#ifndef NULL
		#define NULL 0
	#endif

	/' Defines the ASCII code that indicates a two-byte key code.
	   A two-byte key code will be returned by GET on SCRN: or INKEY$. '/
	#define FB_EXT_CHAR           (cast(ubyte,255))

	/' Maximum number of temporary string descriptors. '/
	#define FB_STR_TMPDESCRIPTORS 256

	/' Maximum number of array dimensions. '/
	#define FB_MAXDIMENSIONS      8

	/' Maximum number of temporary array descriptors. '/
	#define FB_ARRAY_TMPDESCRIPTORS (FB_STR_TMPDESCRIPTORS / 4)

	/' The padding width (for PRINT ,). '/
	#define FB_TAB_WIDTH          14

	#if FB_TAB_WIDTH = 8
		#define FB_NATIVE_TAB 1
	#endif

	/' Screen width/height returned by default when native console function failed.
	   This is required when an applications output is redirected. '/
	#define FB_SCRN_DEFAULT_WIDTH  80
	#define FB_SCRN_DEFAULT_HEIGHT 25

	/' Default colors for console color() function '/
	#define FB_COLOR_FG_DEFAULT   &h1
	#define FB_COLOR_BG_DEFAULT   &h2

	/' Number of reserved file handles. 0: SCRN, 1: LPT1 '/
	#define FB_RESERVED_FILES     2

	/' Maximum number of file handles. '/
	#define FB_MAX_FILES          (FB_RESERVED_FILES + 255)

	/' File buffer size (for buffered read?). '/
	#define FB_FILE_BUFSIZE       8192

	/' Max length to allocated for a temporary buffer on stack '/
	#define FB_LOCALBUFF_MAXLEN   32768

	#ifndef HOST_WIN32
		/' Maximum path length for Non-Win32 targets. For Win32 targets, this
		   value will be set automatically by windows.h. '/
		#define MAX_PATH    1024
	#endif

	/' Convert char to int without sign-extension. '/
	#define FB_CHAR_TO_INT(ch)  (cast(long, cast(ulong, cast(ubyte, ch))))

	/' Build an extended 2 byte key code like those returned by getkey()
	   (inkey() returns a string like &hFF &h49 [page up key code],
	   getkey() returns the same but in a little-endian long: &h49FF
	   where &hFF is the FB_EXT_CHAR  '/
	#define FB_MAKE_EXT_KEY(ch) (cast(long, (cast(ulong ,(cast(ubyte,ch)) shl 8)) + (cast(ulong, (cast(ubyte ,FB_EXT_CHAR))))))
	#define _MIN(a,b)		(iif((a) < (b), (a), (b)))
	#define _MAX(a,b)		(iif((a) > (b), (a), (b)))
	#define _MID(a,b,c)		(MIN(MAX((a), (b)), (c)))
	#define _CINT(x)		(iif((x) > 0.0 ,cast(long, x)+ 0.5,cast(long,(x - 0.5))))

	#define _SWAP(a,b)		((a) xor= (b): (b) xor= (a): (a) xor= (b))

	#if defined(HOST_DOS)
		#include "dos/fb_dos.h"
	#elseif defined(HOST_UNIX)
		#include "unix/fb_unix.h"
	#elseif defined(HOST_WIN32)
		#include "win32/fb_win32.bi"
	#elseif defined(HOST_XBOX)
		#include "xbox/fb_xbox.h"
	#endif

	#if defined(HOST_SOLARIS)
		#undef alloca
		#define alloca(x) __builtin_alloca(x)
	#endif
	extern "C"
	#if defined (ENABLE_MT) And Not(defined (HOST_DOS)) And Not(defined (HOST_XBOX))
		Declare Sub fb_Lock FBCALL( Any )
		Declare Sub fb_Unlock FBCALL( Any )
		Declare Sub fb_StrLock FBCALL( Any )
		Declare Sub fb_StrUnlock FBCALL( Any )
		Declare Sub fb_GraphicsLock FBCALL( Any )
		Declare Sub fb_GraphicsUnlock FBCALL( Any )
	#else
		#define FB_LOCK()
		#define FB_UNLOCK()
		#define FB_STRLOCK()
		#define FB_STRUNLOCK()
		#define FB_GRAPHICS_LOCK()
		#define FB_GRAPHICS_UNLOCK()
	#endif

	/' We use memcmp from C because the compiler might replace this by a built-in
	 * function which will definately be faster than our own implementation in C. '/
	#define FB_MEMCMP(p1, p2, _len) memcmp( p1, p2, _len )
	#define FB_MEMCPY( dest, src, n ) memcpy(dest, src, n)
	#define FB_MEMCHR( s, c, n ) memchr( s, c, n )

	/' We have to wrap memcpy here because our MEMCPYX should return the position
	* after the destination string. '/
	function FB_MEMCPYX( dest as any ptr, src as any const ptr, n as size_t ) as any ptr
		memcpy(dest, src, n)
		return (cast(ubyte ptr, dest))+n
	end function

	function FB_MEMLEN( s as any const ptr, c as long, n as size_t ) as size_t
		Dim pachData as ubyte ptr = cast(ubyte const ptr, s)
		while (n)
			n-= 1
			if( pachData[n] <> cast(ubyte,c) ) then
				return n+1
			end if
		wend
		return 0
	end function

	#define RORW(num, bits) num = (((((num) and &hFFFF) shr (bits) ) | ((num) shl (16 - bits))) and &hFFFF)
	#define RORW1(num)      RORW(num, 1)

	#ifdef __FB_DEBUG__
		#define DBG_ASSERT(e) assert(e)
	#else
		#define DBG_ASSERT(e) (cast(any ptr, 0))
	#endif

	#define fb_hSign( x ) (iif((x) < 0), -1 , 1)

	/' internal lists '/
	type FB_LISTELEM
		as FB_LISTELEM ptr prev
		as FB_LISTELEM ptr next
	end type

	type FB_LIST
		as long cnt      		/' Number of used elements '/
		as FB_LISTELEM ptr head    	/' First used element '/
		as FB_LISTELEM ptr tail		/' Last used element '/
		as FB_LISTELEM ptr fhead   	/' First free element '/
	end type

	declare sub fb_hListInit			( list as FB_List ptr, table as any ptr, elem_size as size_t, size as size_t )
	declare function fb_hListAllocElem	( list as FB_LIST ptr ) as FB_LISTELEM ptr
	declare sub fb_hListFreeElem		( list as FB_LIST ptr, elem as FB_LISTELEM ptr )
	declare sub fb_hListDynInit         ( list as FB_LIST ptr )
	declare sub fb_hListDynElemAdd      ( list as FB_LIST ptr, elem as FB_LISTELEM ptr )
	declare sub fb_hListDynElemRemove   ( list as FB_LIST ptr, elem as FB_LISTELEM ptr )

	/'  Include as added.'/
	#include "fb_unicode.bi"
	#include "fb_error.bi"
	#include "fb_string.bi"
	#include "fb_array.bi"
	#include "fb_system.bi"
	#include "fb_math.bi"
	/'#include "fb_data.bi"
	#include "fb_console.bi"'/
	#include "fb_file.bi"
	/'#include "fb_print.bi"
	#include "fb_device.bi"
	#include "fb_serial.bi"
	#include "fb_printer.bi"'/
	#include "fb_datetime.bi"
	#include "fb_thread.bi"
	#include "fb_hook.bi"
	/'#include "fb_oop.bi"
	#include "fb_legacy.bi"
	'/
	/' DOS keyboard scancodes '/
	#define SC_ESCAPE		&h01
	#define SC_1			&h02
	#define SC_2			&h03
	#define SC_3			&h04
	#define SC_4			&h05
	#define SC_5			&h06
	#define SC_6			&h07
	#define SC_7			&h08
	#define SC_8			&h09
	#define SC_9			&h0A
	#define SC_0			&h0B
	#define SC_MINUS		&h0C
	#define SC_EQUALS		&h0D
	#define SC_BACKSPACE	&h0E
	#define SC_TAB			&h0F
	#define SC_Q			&h10
	#define SC_W			&h11
	#define SC_E			&h12
	#define SC_R			&h13
	#define SC_T			&h14
	#define SC_Y			&h15
	#define SC_U			&h16
	#define SC_I			&h17
	#define SC_O			&h18
	#define SC_P			&h19
	#define SC_LEFTBRACKET	&h1A
	#define SC_RIGHTBRACKET	&h1B
	#define SC_ENTER		&h1C
	#define SC_CONTROL		&h1D
	#define SC_A			&h1E
	#define SC_S			&h1F
	#define SC_D			&h20
	#define SC_F			&h21
	#define SC_G			&h22
	#define SC_H			&h23
	#define SC_J			&h24
	#define SC_K			&h25
	#define SC_L			&h26
	#define SC_SEMICOLON	&h27
	#define SC_QUOTE		&h28
	#define SC_TILDE		&h29
	#define SC_LSHIFT		&h2A
	#define SC_BACKSLASH	&h2B
	#define SC_Z			&h2C
	#define SC_X			&h2D
	#define SC_C			&h2E
	#define SC_V			&h2F
	#define SC_B			&h30
	#define SC_N			&h31
	#define SC_M			&h32
	#define SC_COMMA		&h33
	#define SC_PERIOD		&h34
	#define SC_SLASH		&h35
	#define SC_RSHIFT		&h36
	#define SC_MULTIPLY		&h37
	#define SC_ALT			&h38
	#define SC_SPACE		&h39
	#define SC_CAPSLOCK		&h3A
	#define SC_F1			&h3B
	#define SC_F2			&h3C
	#define SC_F3			&h3D
	#define SC_F4			&h3E
	#define SC_F5			&h3F
	#define SC_F6			&h40
	#define SC_F7			&h41
	#define SC_F8			&h42
	#define SC_F9			&h43
	#define SC_F10			&h44
	#define SC_NUMLOCK		&h45
	#define SC_SCROLLLOCK	&h46
	#define SC_HOME			&h47
	#define SC_UP			&h48
	#define SC_PAGEUP		&h49
	#define SC_LEFT			&h4B
	#define SC_CLEAR		&h4C
	#define SC_RIGHT		&h4D
	#define SC_PLUS			&h4E
	#define SC_END			&h4F
	#define SC_DOWN			&h50
	#define SC_PAGEDOWN		&h51
	#define SC_INSERT		&h52
	#define SC_DELETE		&h53
	#define SC_F11			&h57
	#define SC_F12			&h58
	#define SC_LWIN			&h5B
	#define SC_RWIN			&h5C
	#define SC_MENU			&h5D
	#define SC_ALTGR		&h64

	#define KEY_BACKSPACE   8
	#define KEY_TAB         !"\t"
	#define KEY_F1          FB_MAKE_EXT_KEY( ";" )
	#define KEY_F2          FB_MAKE_EXT_KEY( "<" )
	#define KEY_F3          FB_MAKE_EXT_KEY( "=" )
	#define KEY_F4          FB_MAKE_EXT_KEY( ">" )
	#define KEY_F5          FB_MAKE_EXT_KEY( "?" )
	#define KEY_F6          FB_MAKE_EXT_KEY( "@" )
	#define KEY_F7          FB_MAKE_EXT_KEY( "A" )
	#define KEY_F8          FB_MAKE_EXT_KEY( "B" )
	#define KEY_F9          FB_MAKE_EXT_KEY( "C" )
	#define KEY_F10         FB_MAKE_EXT_KEY( "D" )
	#define KEY_F11         FB_MAKE_EXT_KEY( "E" )
	#define KEY_F12         FB_MAKE_EXT_KEY( "F" )
	#define KEY_HOME        FB_MAKE_EXT_KEY( "G" )
	#define KEY_UP          FB_MAKE_EXT_KEY( "H" )
	#define KEY_PAGE_UP     FB_MAKE_EXT_KEY( "I" )
	#define KEY_LEFT        FB_MAKE_EXT_KEY( "K" )
	#define KEY_CLEAR       FB_MAKE_EXT_KEY( "L" )
	#define KEY_RIGHT       FB_MAKE_EXT_KEY( "M" )
	#define KEY_END         FB_MAKE_EXT_KEY( "O" )
	#define KEY_DOWN        FB_MAKE_EXT_KEY( "P" )
	#define KEY_PAGE_DOWN   FB_MAKE_EXT_KEY( "Q" )
	#define KEY_INS         FB_MAKE_EXT_KEY( "R" )
	#define KEY_DEL         FB_MAKE_EXT_KEY( "S" )
	#define KEY_QUIT        FB_MAKE_EXT_KEY( "k" )

	declare function fb_hMakeInkeyStr( ch as long ) as FBSTRING ptr
	declare function fb_hScancodeToExtendedKey( scancode as long ) as long

	/' This should match fbc's lang enum '/
	enum FB_LANG
		FB_LANG_FB
		FB_LANG_FB_DEPRECATED
		FB_LANG_FB_FBLITE
		FB_LANG_QB
		FB_LANGS
	end enum

	type FB_RTLIB_CTX
		as long argc
		as ubyte ptr ptr argv
		as FBSTRING null_desc
		as ubyte ptr errmsg
		as FB_HOOKSTB hooks
		as FB_FILE fileTB(0 to FB_MAX_FILES - 1)
		as long do_file_reset
		as long lang
		as Sub ptr exit_gfxlib2
	end type

	dim shared as FB_RTLIB_CTX __fb_ctx
	end extern
#endif
/'__FB_BI__'/
