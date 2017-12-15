/' chrw$ routine '/

#include "fb.bi"

extern "C"
function fb_WstrChr ( args as long, ... ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr dst, s
	dim as any ptr ap
	dim as ulong num
	dim as long i

	if ( args <= 0 ) then
		return NULL
	end if

	/' alloc temp string '/
	'va_start( ap, args )
	ap = va_first()
	
    dst = fb_wstr_AllocTemp( args )
	if ( dst <> NULL ) then
		/' convert '/
		s = dst
		for i = 0 to args - 1
			num = va_arg( ap, ulong )
			s += 1
			*s = num
		next
		/' null-term '/
		*s = 0
	end if

	'va_end( ap );

	return dst
end function
end extern