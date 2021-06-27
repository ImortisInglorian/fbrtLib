/' hex$ routine for long long's '/

#include "fb.bi"

dim shared as ubyte hex_table(0 to 15) = {48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70}

extern"C"
function fb_HEXEx_l FBCALL ( num as ulongint, digits as long ) as FBSTRING ptr
	dim as FBSTRING ptr s
	dim as long i
	dim as ulongint num2

	if ( digits <= 0 ) then
		/' Only use the minimum amount of digits needed; need to count
		   the important 4-bit (base 16) chunks in the number.
		   And if it's zero, use 1 digit for 1 zero. '/
		digits = 0
		num2 = num
		while ( num2 )
			digits += 1
			num2 shr= 4
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
		s->data[i] = hex_table(num and &hF)
		num shr= 4
		i -= 1
	wend

	s->data[digits] = asc( "0" )
	return s
end function

function fb_HEX_l FBCALL ( num as ulongint ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0 )
end function
end extern