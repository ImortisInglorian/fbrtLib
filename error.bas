/' runtime error handling '/

#include "fb.bi"

dim shared messages(0 to 17) as ubyte ptr
messages(0) = sadd("")                                      /' FB_RTERROR_OK '/
messages(1) = sadd("illegal function call")                 /' FB_RTERROR_ILLEGALFUNCTIONCALL '/
messages(2) = sadd("file not found")                        /' FB_RTERROR_FILENOTFOUND '/
messages(3) = sadd("file I/O error")                        /' FB_RTERROR_FILEIO '/
messages(4) = sadd("out of memory")                         /' FB_RTERROR_OUTOFMEM '/
messages(5) = sadd("illegal resume")                        /' FB_RTERROR_ILLEGALRESUME '/
messages(6) = sadd("out of bounds array access")            /' FB_RTERROR_OUTOFBOUNDS '/
messages(7) = sadd("null pointer access")                   /' FB_RTERROR_NULLPTR '/
messages(8) = sadd("no privileges")                         /' FB_RTERROR_NOPRIVILEGES '/
messages(9) = sadd(!"\"interrupted\" signal")               /' FB_RTERROR_SIGINT '/
messages(10) = sadd(!"\"illegal instruction\" signal")      /' FB_RTERROR_SIGILL '/
messages(11) = sadd(!"\"floating point error\" signal")     /' FB_RTERROR_SIGFPE '/
messages(12) = sadd(!"\"segmentation violation\" signal")   /' FB_RTERROR_SIGSEGV '/
messages(13) = sadd(!"\"termination request\" signal")      /' FB_RTERROR_SIGTERM '/
messages(14) = sadd(!"\"abnormal termination\" signal")     /' FB_RTERROR_SIGTERM '/
messages(15) = sadd(!"\"quit request\" signal")             /' FB_RTERROR_SIGABRT '/
messages(16) = sadd("return without gosub")                 /' FB_RTERROR_RETURNWITHOUTGOSUB '/
messages(17) = sadd("end of file")                          /' FB_RTERROR_ENDOFFILE '/

extern "C"

sub fb_Die ( err_num as long, line_num as long, mod_name as ubyte const ptr, fun_name as ubyte const ptr )
	dim as long _pos = 0

	_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, "\nAborting due to runtime error %d", err_num )

	if ( (err_num >= 0) and (err_num < FB_RTERROR_MAX) ) then
		_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, " (%s)", messages(err_num) )
	end if
	if ( line_num > 0 ) then
		_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, " at line %d", line_num )
	end if

	if ( mod_name <> NULL ) then
		if( fun_name <> NULL ) then
			_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, " %s %s::%s()\n\n", cast(ubyte ptr,iif(line_num > 0, sadd("of"), sadd("in"))), cast(ubyte ptr, mod_name), cast(ubyte ptr, fun_name) )
		else
			_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, " %s %s()\n\n", cast(ubyte ptr,iif(line_num > 0, sadd("of"), sadd("in"))), cast(ubyte ptr, mod_name) )
		end if
	else
		_pos += snprintf( @__fb_errmsg(_pos), FB_ERRMSG_SIZE - _pos, "\n\n" )
	end if
	__fb_errmsg(FB_ERRMSG_SIZE-1) = 0

	/' Let fb_hRtExit() show the message '/
	__fb_ctx.errmsg = @__fb_errmsg(0)

	fb_End( err_num )
end sub

function fb_ErrorThrowEx cdecl ( err_num as long, line_num as long, mod_name as ubyte const ptr, res_label as any ptr, resnext_label as any ptr ) as FB_ERRHANDLER
    dim as FB_ERRORCTX ptr ctx = _FB_TLSGETCTX( ERROR )

    if ( ctx->handler ) then
    	ctx->err_num = err_num
    	ctx->line_num = line_num
    	if ( mod_name <> NULL ) then
    		ctx->mod_name = mod_name
		end if
    	ctx->res_lbl = res_label
    	ctx->resnxt_lbl = resnext_label

    	return ctx->handler
    end if

	/' if no user handler defined, die '/
	fb_Die( err_num, line_num, iif(mod_name <> NULL, mod_name, ctx->mod_name), ctx->fun_name )

	return NULL
end function

function fb_ErrorThrowAt ( line_num as long, mod_name as ubyte const ptr, res_label as any ptr, resnext_label as any ptr ) as FB_ERRHANDLER
	dim as FB_ERRORCTX ptr ctx = _FB_TLSGETCTX( ERROR )

	return fb_ErrorThrowEx( ctx->err_num, line_num, mod_name, res_label, resnext_label )
end function

function fb_ErrorSetHandler FBCALL ( newhandler as FB_ERRHANDLER ) as FB_ERRHANDLER
	dim as FB_ERRORCTX ptr ctx = _FB_TLSGETCTX( ERROR )
	dim as FB_ERRHANDLER oldhandler

    oldhandler = ctx->handler

    ctx->handler = newhandler

	return oldhandler
end function

function fb_ErrorResume( ) as any ptr
    dim as FB_ERRORCTX ptr ctx = _FB_TLSGETCTX( ERROR )
    dim as any ptr label = ctx->res_lbl

	/' not defined? die '/
	if ( label = NULL ) then
		fb_Die( FB_RTERROR_ILLEGALRESUME, -1, ctx->mod_name, ctx->fun_name )
	end if

	/' don't loop forever '/
	ctx->res_lbl = NULL
	ctx->resnxt_lbl = NULL

	return label
end function

function fb_ErrorResumeNext( ) as any ptr
    dim as FB_ERRORCTX ptr ctx = _FB_TLSGETCTX( ERROR )
    dim as any ptr label = ctx->resnxt_lbl

	/' not defined? die '/
	if ( label = NULL ) then
		fb_Die( FB_RTERROR_ILLEGALRESUME, -1, ctx->mod_name, ctx->fun_name )
	end if

	/' don't loop forever '/
	ctx->res_lbl = NULL
	ctx->resnxt_lbl = NULL

	return label
end function
end extern