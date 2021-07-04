/' oct$ routine for long long's '/

#include "fb.bi"

extern "C"
function fb_OCTEx_l FBCALL ( num as ulongint, digits as long ) as FBSTRING ptr
	dim as FBSTRING ptr s
	dim as long i
	dim as ulongint num2

	if ( digits <= 0 ) then
		/' Only use the minimum amount of digits needed; need to count
		   the important 3-bit (base 8) chunks in the number.
		   And if it's zero, use 1 digit for 1 zero. '/
		digits = 0
		num2 = num
		while ( num2 )
			digits += 1
			num2 shr= 3
		wend
		if ( digits = 0 ) then
			digits = 1
		end if
	end if

	s = fb_hStrAllocTemp( NULL, digits )
	if ( s = NULL ) then
		return @__fb_ctx.null_desc
	end if

	i = digits - 1
	while ( i >= 0 )
		s->data[i] = asc( "0" ) + (num and 7) /' '0'..'7' '/
		num shr= 3
		i -= 1
	wend

	s->data[digits] = asc( !"\000" ) '' NUL CHAR
	return s
end function

function fb_OCT_l FBCALL ( num as ulongint ) as FBSTRING ptr
	return fb_OCTEx_l( num, 0 )
end function
end extern