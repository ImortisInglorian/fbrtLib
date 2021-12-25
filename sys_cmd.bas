/' command$ '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_Command FBCALL ( arg as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as ssize_t i, _len

	/' return all arguments? '/
	if ( arg < 0 ) then
		/' no args? '/
		if ( __fb_ctx.argc <= 1 ) then
			Goto funExit
		end if

		/' concatenate all args but 0 '/
		_len = 0
		for i = 1 to __fb_ctx.argc - 1
			_len += strlen( __fb_ctx.argv[i] )
		next

		if ( fb_hStrAlloc( @dst, _len + __fb_ctx.argc-2 ) <> NULL ) then
			dim as ubyte ptr dst_data = dst.data

			dst_data[0] = 0
			for i = 1 to __fb_ctx.argc - 1
				strcat( dst_data, __fb_ctx.argv[i] )
				if ( i <> __fb_ctx.argc-1 ) then
					strcat( dst_data, " " )
				end if
			next
		end if

	else

		/' return just one argument '/
		if ( arg >= __fb_ctx.argc ) then
			Goto funExit
		end if

		_len = strlen( __fb_ctx.argv[arg] )
		if ( fb_hStrAlloc( @dst, _len ) <> NULL ) then
			dim as ubyte ptr dst_data = dst.data

			strcpy( dst_data, __fb_ctx.argv[arg] )

#ifdef HOST_DOS
			if( arg = 0 ) then
				/' make drive letter uppercase '/
				if ( dst_data[1] = asc(":") ) then
					dst_data[0] = toupper( dst_data[0] )
				end if

				/' DOS gives us argv[0] with '/' path separators -
				 * change them to the more DOS-like "\". '/
				for i = 0 to _len - 1
					if ( dst_data[i] = asc("/") ) then
						dst_data[i] = asc(!"\\")
					end if
				next
			end if
#endif
		end if
	end if

funExit:
	fb_StrSwapDesc( @dst, result )
	return result
end function
end extern