/' bin$ routine for long long's '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_BINEx_l FBCALL ( num as ulongint, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim s as destructable_string
	dim i as long
	dim num2 as ulongint

	DBG_ASSERT( result <> NULL )

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

	if ( fb_hStrAlloc( @s, digits ) <> NULL ) then
		dim s_data as ubyte ptr = s.data
		i = digits - 1
		while( i >= 0 )
			s_data[i] = asc( "0" ) + (num and 1) /' '0' or '1' '/
			num shr= 1
			i -= 1
		wend

		s_data[digits] = asc( !"\000" ) '' NUL CHAR
	end if

	fb_StrSwapDesc( @s, result )
	return result
end function

function fb_BIN_l FBCALL ( num as ulongint, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_BINEx_l( num, 0, result )
end function
end extern