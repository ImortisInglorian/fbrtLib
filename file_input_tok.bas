/' input function core '/

#include "fb.bi"

extern "C"
private function hReadChar( ctx as FB_INPUTCTX ptr ) as long
    /' device? '/
    if ( FB_HANDLE_USED(ctx->handle) <> 0 ) then
		dim as long res, c
		dim as size_t _len
        res = fb_FileGetDataEx( ctx->handle, 0, @c, 1, @_len, FALSE, FALSE )
        if( (res <> FB_RTERROR_OK) or (_len = 0) ) then
            return EOF_
		end if

        return c and &h000000FF
    /' console.. '/
    else
		if ( ctx->index >= FB_STRSIZE( @ctx->str ) ) then
			return EOF_
		else
			return ctx->str->data[ctx->index + 1]
		end if
	end if
end function

private function hUnreadChar( ctx as FB_INPUTCTX ptr, c as long ) as long
    /' device? '/
    if ( FB_HANDLE_USED(ctx->handle) <> 0 ) then
        return fb_FilePutBackEx( ctx->handle, @c, 1 )
    /' console .. '/
    else
		if ( ctx->index <= 0 ) then
			return FALSE
		else
			ctx->index -= 1
			return TRUE
		end if
	end if
end function

private function hSkipWhiteSpc( ctx as FB_INPUTCTX ptr ) as long
	dim as long c

	/' skip white space '/
	do
		c = hReadChar( ctx )
		if( c = EOF_ ) then
			exit do
		end if
	loop while ( (c = 32) or (c = 9) )

	return c
end function

private sub hSkipDelimiter( ctx as FB_INPUTCTX ptr, c as long )
	/' skip white space '/
	while ( (c = 32) or (c = 9) )
		c = hReadChar( ctx )
	wend

	select case ( c )
		case 44, EOF_:
			'nothing

		case 10:
			'nothing

		case 13:
			c = hReadChar( ctx )
			if (c  <> 10 ) then
				hUnreadChar( ctx, c )
			end if

		case else:
			hUnreadChar( ctx, c )
	end select
end sub

function fb_FileInputNextToken( buffer as ubyte ptr, max_chars as ssize_t, is_string as long, isfp as long ptr ) as long
	/' max_chars does not include the null terminator, the buffer is
	   assumed to be big enough to hold at least the null terminator '/

	dim as long c, isquote, hasamp, skipdelim
	dim as ssize_t _len
	dim as FB_INPUTCTX ptr ctx = _FB_TLSGETCTX( INPUT )

	*isfp = FALSE

	/' '/
	skipdelim = TRUE
	isquote = FALSE
	hasamp = FALSE
	_len = 0

	c = hSkipWhiteSpc( ctx )

	while( (c <> EOF_) and (_len < max_chars) )
		select case ( c )
			case 10:
				skipdelim = FALSE
				goto _exit_

			case 13:
				c = hReadChar( ctx )
				if ( c <> 10 ) then
					hUnreadChar( ctx, c )
				end if

				skipdelim = FALSE
				goto _exit_

			case 34:
				if ( isquote = 0 ) then
					if ( _len = 0 ) then
						isquote = TRUE
					else
						goto savechar
					end if
				else
					isquote = FALSE
					if ( is_string ) then
						c = hReadChar( ctx )
						goto _exit_
					end if
				end if

			case 44:
				if ( isquote = 0 ) then
					skipdelim = FALSE
					goto _exit_
				end if

				goto savechar

			case 38:
				hasamp = TRUE
				goto savechar

			case 68, 100, 69, 101, 46:
				/' NOTE: if exponent letter is d|D, and
				 * is_string == FALSE, then convert the d|D
				 * to an e|E. strtod() which
				 * will later be used to convert the string
				 * to float won't accept d|D anywhere but
				 * on windows. (jeffm)
				 '/
				if (c = 68 orelse c = 100 ) then
					if ( hasamp = 0 and is_string = 0 ) then
						c += 1
					end if
				end if
				/' fall through '/

				if ( hasamp = 0 ) then
					*isfp = TRUE
				end if
				goto savechar

			case 32, 9:
				if ( isquote = 0 ) then
					if ( is_string = 0 ) then
						goto _exit_
					end if
				end if

			case else:
savechar:
				buffer += 1
				*buffer = c
				_len += 1
		end select

		c = hReadChar( ctx )
	wend

_exit_:
	/' add the null-term '/
	*buffer = 0

	/' skip comma or newline '/
	if ( skipdelim <> 0 ) then
		hSkipDelimiter( ctx, c )
	end if

	return _len
end function
end extern