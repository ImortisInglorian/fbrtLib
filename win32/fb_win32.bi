
#ifdef HOST_X86
#define FBCALL stdcall
#else
#define FBCALL
#endif

/' newline for console/file I/O '/
#define FB_NEWLINE !"\r\n"
#define FB_NEWLINE_WSTR _LC(!"\r\n")

/' newline for printer I/O '/
#define FB_BINARY_NEWLINE !"\r\n"
#define FB_BINARY_NEWLINE_WSTR _LC(!"\r\n")

#if defined( HOST_CYGWIN )
	#define FB_LL_FMTMOD "ll"
#else
	/' ucrt and mingw-w64's implementation of printf format specifers
	   require that long long use the 'll' specifier instead of 'I64' 
	'/
	#ifndef __USE_MINGW_ANSI_STDIO
		#define __USE_MINGW_ANSI_STDIO 0
	#endif
	#if defined(_UCRT) orelse __USE_MINGW_ANSI_STDIO 
		#define FB_LL_FMTMOD "ll"
	#else
		#define FB_LL_FMTMOD "I64"
	#endif
#endif

#define FB_LL_FMTMOD "I64"

#define FB_CONSOLE_MAXPAGES 4

type fb_off_t as longint
#define fseeko(stream, offset, whence) fseeko64(stream, offset, whence)
#define ftello(stream)                 ftello64(stream)

#define FB_COLOR_BLACK    (0)
#define FB_COLOR_BLUE     (FOREGROUND_BLUE)
#define FB_COLOR_GREEN    (FOREGROUND_GREEN)
#define FB_COLOR_CYAN     (FOREGROUND_GREEN or FOREGROUND_BLUE)
#define FB_COLOR_RED      (FOREGROUND_RED)
#define FB_COLOR_MAGENTA  (FOREGROUND_RED or FOREGROUND_BLUE)
#define FB_COLOR_BROWN    (FOREGROUND_RED or FOREGROUND_GREEN)
#define FB_COLOR_WHITE    (FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE)
#define FB_COLOR_GREY     (FOREGROUND_INTENSITY)
#define FB_COLOR_LBLUE    (FOREGROUND_BLUE or FOREGROUND_INTENSITY)
#define FB_COLOR_LGREEN   (FOREGROUND_GREEN or FOREGROUND_INTENSITY)
#define FB_COLOR_LCYAN    (FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY)
#define FB_COLOR_LRED     (FOREGROUND_RED or FOREGROUND_INTENSITY)
#define FB_COLOR_LMAGENTA (FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_INTENSITY)
#define FB_COLOR_YELLOW   (FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_INTENSITY)
#define FB_COLOR_BWHITE   (FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY)

extern "C"
#ifdef ENABLE_MT
	declare sub fb_MtLock FBCALL( )
	declare sub fb_MtUnlock FBCALL( )
	#define FB_MT_LOCK()   fb_MtLock()
	#define FB_MT_UNLOCK() fb_MtUnlock()
#else
	#define FB_MT_LOCK()
	#define FB_MT_UNLOCK()
#endif
end extern
