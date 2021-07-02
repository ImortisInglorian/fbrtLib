/' input function core '/

#include "fb.bi"

extern "C"
private function hReadChar( ctx as FB_INPUTCTX ptr ) as FB_WCHAR
    /' device? '/
    if ( FB_HANDLE_USED(ctx->handle) <> 0 ) then
        dim as long res
        dim as FB_WCHAR c

        dim as size_t _len
        res = fb_FileGetDataEx( ctx->handle, 0, @c, 1, @_len, FALSE, TRUE )
        if ( (res <> FB_RTERROR_OK) orelse (_len = 0) ) then
            return FB_WEOF
		end if

        return c
    /' console.. '/
    else
		if ( ctx->index >= FB_STRSIZE( @ctx->str ) ) then
			return FB_WEOF
		else
			ctx->index += 1
			/' !!!FIXME!!! - casting to ubyte? this function returns FB_CHAR '/
			return cast(ubyte, ctx->str.data[ctx->index - 1])
		end if
	end if

end function

private function hUnreadChar( ctx as FB_INPUTCTX ptr, c as FB_WCHAR ) as long
    /' device? '/
    if ( FB_HANDLE_USED(ctx->handle) <> 0 ) then
        return fb_FilePutBackWstrEx( ctx->handle, @c, 1 )
    /' console .. '/
    else
		if ( ctx->index <= 0 ) then
			return 0
		else
			ctx->index -= 1
			return 1
		end if
	end if
end function

private function  hSkipWhiteSpc( ctx as FB_INPUTCTX ptr ) as FB_WCHAR
	dim as FB_WCHAR c

	/' skip white space '/
	do
		c = hReadChar( ctx )
		if ( c = FB_WEOF ) then
			exit do
		end if
	loop while( (c = asc(" ") ) or (c = asc(!"\t")) )

	return c
end function

private sub hSkipDelimiter( ctx as FB_INPUTCTX ptr, c as FB_WCHAR )
	/' skip white space '/
	while ( c = asc(" ")  or c = asc(!"\t") )
		c = hReadChar( ctx )
	wend

	select case ( c )
		case asc(","), FB_WEOF:
			'nothing

		case asc(!"\n"):
			'nothing

		case asc(!"\r"):
			c = hReadChar( ctx )
			if ( c <> asc(!"\n") ) then
				hUnreadChar( ctx, c )
			end if

		case else:
			hUnreadChar( ctx, c )
	end select
end sub

sub fb_FileInputNextTokenWstr( buffer as FB_WCHAR ptr, max_chars as ssize_t, is_string as long )
	/' max_chars does not include the null terminator, the buffer is
	   assumed to be big enough to hold at least the null terminator '/

	dim as ssize_t _len
	dim as long isquote, skipdelim
    dim as FB_WCHAR c
	dim as FB_INPUTCTX ptr ctx = _FB_TLSGETCTX( INPUT )

	/' '/
	skipdelim = TRUE
	isquote = 0
	_len = 0

	c = hSkipWhiteSpc( ctx )

	while( (c <> FB_WEOF) and (_len < max_chars) )
		select case ( c )
			case asc(!"\n"):
				skipdelim = FALSE
				goto _exit_

			case asc(!"\r"):
				c = hReadChar( ctx )
				if ( c <> asc(!"\n") ) then
					hUnreadChar( ctx, c )
				end if

				skipdelim = FALSE
				goto _exit_

			case asc(!"\""):
				if ( isquote = 0 ) then
					if ( _len = 0 ) then
						isquote = 1
					else
						goto savechar
					end if
				else
					isquote = 0
					if ( is_string <> 0 ) then
						c = hReadChar( ctx )
						goto _exit_
					end if
				end if

			case asc(","):
				if ( isquote = 0 ) then
					skipdelim = FALSE
					goto _exit_
				end if

				goto savechar

			case asc(!"\t"), asc(" "):
				if ( isquote = 0 ) then
					if ( is_string  = 0 ) then
						goto _exit_
					end if
				end if
				goto savechar

			case else:
	savechar:
				*buffer = c
				buffer += 1
				_len += 1
		end select

		c = hReadChar( ctx )
	wend

_exit_:
	*buffer = 0

	/' skip comma or newline '/
	if ( skipdelim <> 0 ) then
		hSkipDelimiter( ctx, c )
	end if
end sub
end extern