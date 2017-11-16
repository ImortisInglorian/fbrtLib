#ifdef fb_ErrorThrowEx
	#undef fb_ErrorThrowEx
	#undef fb_ErrorThrowAt
	#undef fb_ErrorSetHandler
	#undef fb_ErrorGetNum
	#undef fb_ErrorSetNum
	#undef fb_ErrorResume
	#undef fb_ErrorResumeNext
	#undef fb_ErrorSetModName
	#undef fb_ErrorSetFuncName
#endif

enum FB_RTERROR
	FB_RTERROR_OK = 0
	FB_RTERROR_ILLEGALFUNCTIONCALL
	FB_RTERROR_FILENOTFOUND
	FB_RTERROR_FILEIO
	FB_RTERROR_OUTOFMEM
	FB_RTERROR_ILLEGALRESUME
	FB_RTERROR_OUTOFBOUNDS
	FB_RTERROR_NULLPTR
	FB_RTERROR_NOPRIVILEGES
	FB_RTERROR_SIGINT
	FB_RTERROR_SIGILL
	FB_RTERROR_SIGFPE
	FB_RTERROR_SIGSEGV
	FB_RTERROR_SIGTERM
	FB_RTERROR_SIGABRT
	FB_RTERROR_SIGQUIT
	FB_RTERROR_RETURNWITHOUTGOSUB
	FB_RTERROR_ENDOFFILE
	FB_RTERROR_MAX
end enum

type FB_ERRHANDLER as Sub()

type FB_ERRORCTX
	as FB_ERRHANDLER 	handler
	as long 			err_num
	as long 			line_num
	as ubyte ptr 		mod_name
	as ubyte ptr 		fun_name
	as any ptr 			res_lbl
	as any ptr 			resnxt_lbl
end type

#define FB_ERRMSG_SIZE 1024
extern as ubyte __fb_errmsg(0 to FB_ERRMSG_SIZE -1)

extern "C"
declare sub 	  fb_Assert 				FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as ubyte ptr )
declare sub 	  fb_AssertWarn 			FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as ubyte ptr )
declare sub 	  fb_AssertW 				FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as FB_WCHAR ptr )
declare sub 	  fb_AssertWarnW 			FBCALL ( filename as ubyte ptr, linenum as long, funcname as ubyte ptr, expression as FB_WCHAR ptr )
declare function fb_ErrorThrowEx 		cdecl  ( errnum as long, linenum as long, fname as ubyte const ptr, res_label as any ptr, resnext_label as any ptr ) as FB_ERRHANDLER
declare function fb_ErrorThrowAt 		cdecl  ( line_num as long, mod_name as ubyte const ptr, res_label as any ptr, resnext_label as any ptr ) as FB_ERRHANDLER
declare function fb_ErrorSetHandler 	FBCALL ( newhandler as FB_ERRHANDLER ) as FB_ERRHANDLER
declare function fb_ErrorGetNum 			FBCALL ( ) as long
declare function fb_ErrorSetNum 			FBCALL ( errnum as long ) as long
declare function fb_ErrorResume     	cdecl  ( ) as any ptr
declare function fb_ErrorResumeNext 	cdecl  ( ) as any ptr
declare function fb_ErrorGetLineNum 	FBCALL ( ) as long
declare function fb_ErrorGetModName 	FBCALL ( ) as ubyte ptr
declare function fb_ErrorSetModName 	FBCALL ( mod_name as ubyte const ptr ) as ubyte ptr
declare function fb_ErrorGetFuncName 	FBCALL ( ) as ubyte ptr
declare function fb_ErrorSetFuncName 	FBCALL ( fun_name as ubyte const ptr ) as ubyte ptr
end extern