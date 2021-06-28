/' hexw$ routine for long long's '/

#include "fb.bi"

dim shared as FB_WCHAR hex_table(0 to 15) = { 48, 49, 50, 51, _
											  52, 53, 54, 55, _
											  56, 57, 65, 66, _
											  67, 68, 69, 70}

extern "C"
function fb_WstrHexEx_l FBCALL ( num as ulongint, digits as long ) as FB_WCHAR ptr
	dim as FB_WCHAR ptr s
	dim as long i
	dim as ulongint num2

	if ( digits <= 0 ) then
		/' Only use the minimum amount of digits needed; need to count
		   the important 4-bit (base 16) chunks in the number.
		   And if it's zero, use 1 digit for 1 zero. '/
		digits = 0
		num2 = num
		while( num2 )
			digits += 1
			num2 shr= 4
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
	while ( i >= 0 )
		s[i] = hex_table(num and &hF)
		num shr= 4
		i -= 1
	wend

	s[digits] = asc(!"\000") '' NUL CHAR
	return s
end function

function fb_WstrHex_l FBCALL ( num as ulongint ) as FB_WCHAR ptr
	return fb_WstrHexEx_l( num, 0 )
end function
end extern