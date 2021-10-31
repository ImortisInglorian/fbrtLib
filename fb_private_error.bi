type _FB_ERRHANDLER As FB_ERRHANDLER

type FB_ERRORCTX
	as _FB_ERRHANDLER   handler
	as long            err_num
	as long            line_num
	as const ubyte ptr mod_name
	as const ubyte ptr fun_name
	as any ptr         res_lbl
	as any ptr         resnxt_lbl
end type

declare function fb_get_thread_errorctx( ) as FB_ERRORCTX ptr