/' chr$ routine '/

#include "fb.bi"

extern "C"
function fb_CHR cdecl ( args as long, ... ) as FBSTRING ptr
	dim dst as FBSTRING ptr
	dim ap as any ptr
	dim num as ulong
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
			num = va_arg( ap, ulong )
			dst->data[i] = cast(ubyte, num)
			ap = va_next(ap, ulong)
		next
		dst->data[args] = 0
	else
		dst = @__fb_ctx.null_desc
	end if
	'va_end( ap )

	return dst
end function
end extern