/' chr$ routine '/

#include "fb.bi"

extern "C"
function fb_CHR cdecl ( args as long, ... ) as FBSTRING ptr
	dim dst as FBSTRING ptr
	dim ap as any ptr
	dim num as uinteger
	dim i as long

	if ( args <= 0 ) then
		return @__fb_ctx.null_desc
	end if
	'va_start( ap, args )
	ap = va_first()

	/' alloc temp string '/
    dst = fb_hStrAllocTemp( NULL, args )
	if ( dst <> NULL ) then
		/' convert '/
		for i = 0 to args
			num = va_arg( ap, uinteger )
			dst->_data[i] = cast(ubyte, num)
			ap = va_next(ap, uinteger)
		next
		dst->_data[args] = 0
	else
		dst = @__fb_ctx.null_desc
	end if
	'va_end( ap )

	return dst
end function
end extern