Extern "C"

Type signal_func As Sub cdecl(byVal sigNum as Long)

Declare Function raise cdecl(ByVal sig as Long) As Long
Declare Function signal cdecl(ByVal sigNum As Long, ByVal func As signal_func) as signal_func

'' Same in Win32 + POSIX
#define SIGINT          2
#define SIGILL          4
#define SIGFPE          8
#define SIGSEGV         11
#define SIGTERM         15

#if defined( HOST_WIN32 )
#define SIGBREAK        21
#define SIGABRT         22
#define NSIG            23
#else
#define SIGABRT         6
#define NSIG            32
#error "Please check the signal ids in crt_extra/signal.bi are correct for this platform"
#endif

End Extern
