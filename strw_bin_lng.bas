/' binw$ routine for long long's '/

#include "fb.bi"

extern "C"
function fb_WstrBinEx_l FBCALL ( num as ulongint, digits as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr s
	dim as long i
	dim as ulongint num2

	if ( digits <= 0 ) then
		/' Only use the minimum amount of digits needed; need to count
		   the important bits in the number. And if there are none set,
		   use 1 digit for 1 zero. '/
		digits = 0
		num2 = num
		while ( num2 )
			digits += 1
			num2 shr= 1
		wend
		if ( digits = 0 ) then
			digits = 1
		end if
	end if

	s = fb_wstr_AllocTemp( digits )
	if ( s = NULL ) then
		return NULL
	end if

	i = digits - 1
	while( i >= 0 )
		s[i] = asc("0") + (num and 1) /' '0' or '1' '/
		num shr= 1
		i -= 1
	wend

	s[digits] = 0
	return s
end function

function fb_WstrBin_l FBCALL ( num as ulongint ) as FB_WCHAR ptr
	return fb_WstrBinEx_l( num, 0 )
end function
end extern