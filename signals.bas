'' signal handlers

#include "fb.bi"
#include "crt_extra/signal.bi"

#if defined( HOST_WIN32 )
#include once "windows.bi"

Dim Shared old_excpfilter As LPTOP_LEVEL_EXCEPTION_FILTER

'' low-level signal handler for Windows
Function exception_filter stdcall( ByVal info As LPEXCEPTION_POINTERS ) As LONG

	Select Case info->ExceptionRecord->ExceptionCode
	
	case EXCEPTION_ACCESS_VIOLATION, _
             EXCEPTION_STACK_OVERFLOW
		raise( SIGSEGV )

	case EXCEPTION_FLT_DIVIDE_BY_ZERO, _
	     EXCEPTION_FLT_OVERFLOW, _
	     EXCEPTION_INT_DIVIDE_BY_ZERO, _
	     EXCEPTION_INT_OVERFLOW
		raise( SIGFPE )
	End Select

	Return old_excpfilter( info )
End Function
#endif

Type FB_SIGHANDLER
    errnum As Long
    oldhnd As signal_func
End Type

static Shared sigTb(NSIG) as FB_SIGHANDLER

#macro FB_SETUPSIGNAL(n,h)
#define SIG_VAL __FB_UNQUOTE__(n)
#define FB_ERR_NUM __FB_EVAL__(__FB_UNQUOTE__(__FB_EVAL__("FB_RTERROR_" + n)))
    sigTb(SIG_VAL).oldhnd = signal( SIG_VAL, @h )
    sigTb(SIG_VAL).errnum = FB_ERR_NUM
#undef SIG_VAL
#undef FB_ERR_NUM
#endmacro

Sub gen_handler cdecl( ByVal sig As Long )

	Dim handler As FB_ERRHANDLER

	/' don't cause another exception '/
	If ( (sig < 0) Or (sig >= NSIG) Or (sigTb(sig).errnum = FB_RTERROR_OK) ) Then
	
		raise( sig )
		Exit Sub
	End If

	/' call user handler if any defined '/
	handler = fb_ErrorThrowEx( sigTb(sig).errnum, -1, NULL, NULL, NULL )

	If( handler <> NULL ) Then
		handler( )
        End If

	/' if the user handler returned, exit '/
	fb_End( sigTb(sig).errnum )
End Sub

Extern "C"
Sub fb_InitSignals FBCALL ( )

	FB_SETUPSIGNAL("SIGABRT", gen_handler)
	FB_SETUPSIGNAL("SIGFPE", gen_handler)
	FB_SETUPSIGNAL("SIGILL", gen_handler)
	FB_SETUPSIGNAL("SIGSEGV", gen_handler)
	FB_SETUPSIGNAL("SIGTERM", gen_handler)
	FB_SETUPSIGNAL("SIGINT", gen_handler)
#ifdef SIGQUIT
	FB_SETUPSIGNAL("SIGQUIT", gen_handler)
#endif

#if defined( HOST_WIN32 )
	old_excpfilter = SetUnhandledExceptionFilter( @exception_filter )
#endif
End Sub
End Extern
