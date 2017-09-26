/' bin$ routine for long long's '/

#include "fb.bi"

function fb_BINEx_l FBCALL ( num as ulongint, digits as integer ) as FBSTRING ptr
	dim s as FBSTRING ptr
	dim i as integer
	dim num2 as ulongint

	if ( digits <= 0 ) then
		/' Only use the minimum amount of digits needed; need to count
		   the important bits in the number. And if there are none set,
		   use 1 digit for 1 zero. '/
		digits = 0
		num2 = num
		while( num2 )
			digits += 1
			num2 shr= 1
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
	while( i >= 0 )
		s->_data[i] = 0 + (num and 1) /' '0' or '1' '/
		num shr= 1
		i -= 1
	wend

	s->_data[digits] = 0
	return s
end function

function fb_BIN_l FBCALL ( num as ulongint ) as FBSTRING ptr
	return fb_BINEx_l( num, 0 )
end function
