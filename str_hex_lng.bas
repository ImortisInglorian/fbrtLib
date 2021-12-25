/' hex$ routine for long long's '/

#include "fb.bi"
#include "destruct_string.bi"

dim shared as ubyte hex_table(0 to 15) = {48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70}

extern"C"
function fb_HEXEx_l FBCALL ( num as ulongint, digits as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string s
	dim as long i
	dim as ulongint num2

	DBG_ASSERT( result <> NULL )

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

	if ( fb_hStrAlloc( @s, digits ) <> NULL ) then
		dim as ubyte ptr s_data = s.data

		i = digits - 1
		while ( i >= 0 )
			s_data[i] = hex_table(num and &hF)
			num shr= 4
			i -= 1
		wend

		s_data[digits] = asc( !"\000" ) '' NUL CHAR
	end if

	fb_StrSwapDesc( @s, result )
	return result
end function

function fb_HEX_l FBCALL ( num as ulongint, result as FBSTRING ptr ) as FBSTRING ptr
	return fb_HEXEx_l( num, 0, result )
end function
end extern