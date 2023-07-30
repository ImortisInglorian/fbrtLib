/' command$ '/

#include "fb.bi"
extern "C"
function fb_Command FBCALL ( arg as long ) as FBSTRING ptr
	dim as FBSTRING ptr dst
	dim as ssize_t i, _len

	/' return all arguments? '/
	if ( arg < 0 ) then
		/' no args? '/
		if ( __fb_ctx.argc <= 1 ) then
			return @__fb_ctx.null_desc
		end if

		/' concatenate all args but 0 '/
		_len = 0
		for i = 1 to __fb_ctx.argc - 1
			_len += strlen( __fb_ctx.argv[i] )
		next

		dst = fb_hStrAllocTemp( NULL, _len + __fb_ctx.argc-2 )
		if ( dst = NULL ) then
			return @__fb_ctx.null_desc
		end if

		dst->data[0] = 0
		for i = 1 to __fb_ctx.argc - 1
			strcat( dst->data, __fb_ctx.argv[i] )
			if ( i <> __fb_ctx.argc-1 ) then
				strcat( dst->data, " " )
			end if
    	next

    	return dst
	end if

    /' return just one argument '/
	if ( arg >= __fb_ctx.argc ) then
	    return @__fb_ctx.null_desc
	end if

	_len = strlen( __fb_ctx.argv[arg] )
	dst = fb_hStrAllocTemp( NULL, _len )
	if ( dst = NULL ) then
		return @__fb_ctx.null_desc
	end if

	strcpy( dst->data, __fb_ctx.argv[arg] )

#ifdef HOST_DOS
	if( arg = 0 ) then
		/' make drive letter uppercase '/
		if ( dst->data[1] = asc(":") ) then
			dst->data[0] = toupper( dst->data[0] )
		end if

		/' DOS gives us argv[0] with '/' path separators -
		 * change them to the more DOS-like "\". '/
		for i = 0 to _len - 1
			if ( dst->data[i] = asc("/") ) then
				dst->data[i] = asc(!"\\")
			end if
		next
	end if
#endif

	return dst
end function
end extern