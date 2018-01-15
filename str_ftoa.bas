/' float to string, internal usage '/

#include "fb.bi"

extern "C"
function fb_hFloat2Str( _val as double, buffer as ubyte ptr, digits as long, mask as long ) as ubyte ptr
	dim as ssize_t _len, maxlen
	dim as ubyte ptr p, fstr
	dim as ubyte fmtstr(0 to 15)

	if ( mask and FB_F2A_ADDBLANK ) then
		p = @buffer[1]
	else
		p = buffer
	end if

	select case digits
		case 7:
			fstr = @"%.7g"
		case 16:
			fstr = @"%.16g"
		case else:
			sprintf( @fmtstr(0), "%%.%dg", digits )
			fstr = @fmtstr(0)
	end select

	maxlen = 1 + digits + 6 + 1

	_len = snprintf( p, maxlen, fstr, _val )

	if ( _len <= 0 or _len >= maxlen ) then
		buffer[0] = 0
		return NULL
	end if

	if ( _len > 0 ) then
		/' skip the dot at end if any '/
		if ( _len > 0 ) then
			if( p[_len - 1] = 46 ) then
				p[_len - 1] = 0
			end if
		end if
	end if

	/' '/
	if ( (mask and FB_F2A_ADDBLANK) > 0 ) then
		if ( p[0] <> 45 ) then
			buffer[0] = 32
			return @buffer[0]
		else
			return p
		end if
	else
		return p
	end if
end function
end extern
