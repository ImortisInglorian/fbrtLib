/' format function '/

#include "fb.bi"
#include "crt/math.bi"

enum eMaskType
	eMT_Unknown = 0
	eMT_Number
	eMT_DateTime
end enum

type FormatMaskInfo
	as eMaskType mask_type

	as long has_decimal_point
	as long has_thousand_sep
	as long has_percent
	as long has_exponent
	as long exponent_add_plus
	as long has_sign
	as long sign_add_plus
	as long num_digits_fix
	as long num_digits_frac
	as long num_digits_omit
	as long exp_digits

	as long has_ampm

	as ssize_t length_min
	as ssize_t length_opt
end type

#define FB_MAXFIXLEN 19 /' floor( log10( pow( 2.0, 64 ) ) ) '/

/'' Splits a number into its fixed and fractional part.
 *
 * precision        info
 * 11               VBDOS' default floating point precision for FORMAT$()
 *                  when no mask was specified
 * 16               Precision when the user specified a mask
 '/
 
 extern "C"
sub fb_hGetNumberParts cdecl ( number as double, pachFixPart as ubyte ptr, pcchLenFix as ssize_t ptr, pachFracPart as ubyte ptr, pcchLenFrac as ssize_t ptr, pchSign as ubyte ptr, chDecimalPoint as ubyte, precision as long )
	dim as ubyte ptr pszFracStart, pszFracEnd
	dim as ubyte chSign
	dim as double dblFix
	dim as double dblFrac = modf( number, @dblFix )
	dim as long neg = (number < 0.0)
	dim as ulongint ullFix = cast(ulongint, iif(neg, -dblFix , dblFix))
	dim as ssize_t len_fix, len_frac

	/' make fractional part positive '/
	if ( dblFrac < 0.0 ) then
		dblFrac = -dblFrac
	end if

	/' Store fractional part of number into buffer '/
	len_frac = sprintf( pachFracPart, "%.*f", precision, dblFrac )

	/' Remove trailing zeroes and - if it completely consists of zeroes -
	* also remove the decimal point '/
	pszFracStart = pachFracPart
	if ( *pszFracStart = asc("-") ) then
		pszFracStart += 1       /' Required for -0.0 value '/
	end if
	pszFracStart += 1
	pszFracEnd = pachFracPart + len_frac
	while ( pszFracEnd <> pszFracStart )
		pszFracEnd -= 1
		if ( *pszFracEnd <> asc( "0" ) ) then
			if ( *pszFracEnd <> chDecimalPoint ) then
				pszFracStart += 1
				pszFracEnd += 1
			end if
			exit while
		end if
	wend

	/' Move usable fractional part of number to begin of buffer '/
	len_frac = pszFracEnd - pszFracStart
	memmove( pachFracPart, pszFracStart, len_frac )
	pachFracPart[len_frac] = 0

	/' Store fix part of the number into buffer '/
	if ( ullFix=0 andalso neg ) then
		pachFixPart[0] = 0
		len_fix = 0
		chSign = asc("-")
	elseif ( ullFix=0 andalso number > 0.0 ) then
		pachFixPart[0] = 0
		len_fix = 0
		chSign = asc("+")
	else
		if ( neg ) then
			chSign = asc("-")
		elseif ( ullFix > 0 ) then
			chSign = asc("+")
		else
			chSign = 0 '' NUL CHAR
		end if
		len_fix = sprintf( pachFixPart, "%" FB_LL_FMTMOD "u", ullFix )
	end if

	if ( pcchLenFix <> NULL ) then
		*pcchLenFix = len_fix
	end if

	if ( pcchLenFrac <> NULL ) then
		*pcchLenFrac = len_frac
	end if

	if ( pchSign <> NULL ) then
		*pchSign = chSign
	end if
end sub

function fb_hBuildDouble cdecl _
	( _
		num as double, _
		decimal_point as ubyte, _
		thousands_separator as ubyte _
	) as FBSTRING ptr

	dim as ubyte FixPart(0 to 127), FracPart(0 to 127), chSign
	dim as ssize_t LenFix, LenFrac, LenSign, LenDecPoint, LenTotal
	dim as FBSTRING ptr dst

	fb_hGetNumberParts( num, @FixPart(0), @LenFix, @FracPart(0), @LenFrac, @chSign, asc("."), 11 )

	LenSign = iif( chSign = asc("-"), 1, 0 )
	LenDecPoint = iif( LenFrac <> 0, 1, 0 )
	LenTotal = LenSign + LenFix + LenDecPoint + LenFrac

	/' alloc temp string '/
	dst = fb_hStrAllocTemp_NoLock( NULL, LenTotal )
	if ( dst <> NULL ) then
		if ( LenSign <> 0 ) then
			dst->data[0] = chSign
		end if
		FB_MEMCPY( dst->data + LenSign, @FixPart(0), LenFix )
		if ( LenDecPoint <> 0 ) then
			dst->data[LenSign + LenFix] = decimal_point
		end if
		FB_MEMCPY( dst->data + LenSign + LenFix + LenDecPoint, @FracPart(0), LenFrac )
		dst->data[LenTotal] = 0
	else
		dst = @__fb_ctx.null_desc
	end if

	return dst
end function

function hRound cdecl ( value as double, pInfo as const FormatMaskInfo ptr ) as double
	dim as double _fix, _frac = modf( value, @_fix )

    if ( pInfo->num_digits_frac = 0 ) then
    	/' round it here, because modf() at GetNumParts won't '/

    		/' convert to fixed-point because the imprecision and the optimizations
	    	   that can be done by gcc (ie: keeping values on fpu stack as twords) '/
    		dim as longint intfrac = cast(longint, _frac * 1.E+15)
	    	if ( intfrac > cast(longint, 5.E+14) ) then
        		value = ceil( value )
		elseif( intfrac < -cast(longint, 5.E+14) ) then
        		value = floor( value )
		end if
	else
		/' remove the fraction of the fraction to be compatible with
		   VBDOS (ie: 2.55 -> 2.5, not 2.6 as in VB6) '/
		if ( _frac <> 0.0 ) then
	    		dim as double p10 = pow( 10.0, pInfo->num_digits_frac )

	        	dim as double fracfrac = modf( _frac * p10, @_frac )

	        	/' convert to fixed-point, see above '/
	        	dim as longint intfrac = cast(longint, fracfrac * (1.E+15 / p10) )

	        	if ( intfrac > cast(longint, 5.E+14 / p10) ) then
	        		_frac += 1.0
	        	elseif ( intfrac < -cast(longint, 5.E+14 / p10) ) then
	        		_frac += -1.0
			end if
			
	        _frac /= p10

	        value = _fix + _frac
		end if
	end if

	return value
end function

/'' Processes a FORMAT mask.
 *
 * This function is used for two passes:
 *
 * - Determine the required size of the resulting string.
 * - Build the resulting string.
 *
 * This function is a mess, but hey, it works ...
 *
 * When I've too much time, I'll simplify this function so that almost all
 * queries of do_output will be removed.
 '/
function fb_hProcessMask cdecl ( dst as FBSTRING ptr, mask as const ubyte ptr, mask_length as ssize_t, value as double, pInfo as FormatMaskInfo ptr, chThousandsSep as ubyte, chDecimalPoint as ubyte, chDateSep as ubyte, chTimeSep as ubyte ) as long
	dim as ubyte FixPart(0 to 127), FracPart(0 to 127), ExpPart(0 to 127), chSign = 0
	dim as ssize_t LenFix, LenFrac, LenExp = 0, IndexFix, IndexFrac, IndexExp = 0
	dim as ssize_t ExpValue, ExpAdjust = 0, NumSkipFix = 0, NumSkipExp = 0, NonZero = 0
	dim as long do_skip = FALSE, do_exp = FALSE, do_string = FALSE
	dim as long did_sign = FALSE, did_exp = FALSE, did_hour = FALSE, did_thousandsep = FALSE
	dim as long do_num_frac = FALSE, last_was_comma = FALSE, was_k_div = FALSE
	dim as long do_output = (dst <> NULL)
	dim as long do_add = FALSE
	dim as ssize_t LenOut
	dim as ubyte ptr pszOut
	dim as ssize_t i

	DBG_ASSERT( pInfo <> NULL )

	if ( do_output = FALSE ) then
		memset( pInfo, 0, sizeof(FormatMaskInfo) )
		pszOut = NULL
		LenOut = 0
	else
		if ( pInfo->mask_type = eMT_Number ) then
			if ( pInfo->has_percent ) then
				value *= 100.0
			end if
			value /= pow( 10.0, pInfo->num_digits_omit )
		end if
		pszOut = dst->data
		LenOut = FB_STRSIZE( dst )
	end if

	if ( value <> 0.0 ) then
		ExpValue = cast(long ,floor( log10( fabs( value ) ) ) + 1)
		NonZero = 1
	else
		ExpValue = 0
		NonZero = 0
	end if

	/' value == 0.nnnnne+ExpValue '/
	
	if ( do_output ) then
		if ( pInfo->mask_type = eMT_Number ) then
			/' When output of exponent is required, shift value to the
			 * left (* 10^n) as far as possible. "As far as possible" depends
			 * on the number of digits required by the number as a textual
			 * representation. '/

			if ( pInfo->has_exponent ) then

				/' if non-zero, scale mantissa to fill fix digits '/
				if ( NonZero ) then
					ExpValue -= pInfo->num_digits_fix
				end if

				if ( ExpValue <> 0 ) then
					if ( -ExpValue <= 308 ) then
						value *= pow( 10.0, -ExpValue )
					else
						value *= pow( 5.0, -ExpValue )
						value *= pow( 2.0, -ExpValue )
					end if
				end if
				
				while( value >= cdbl( 18446744073709551615# ) )
					value /= 10.0
					ExpValue += 1
				wend

				LenExp = sprintf( @ExpPart(0), "%d", cast(long, ExpValue) )

				if( ExpValue < 0 ) then
					IndexExp = 1
					ExpAdjust = 1
				else
					IndexExp = 0
					ExpAdjust = 0
				end if

				NumSkipExp = pInfo->exp_digits - ( LenExp - ExpAdjust )
			/' value between (+|-)0.0..1.0 '/
			elseif ( ExpValue < 0 ) then
				/' too small? '/
				if ( -ExpValue >= pInfo->num_digits_frac ) then
					#if 0
					/' can't scale? '/
					if ( (pInfo->num_digits_frac = 0 ) orelse (-ExpValue > pInfo->num_digits_fix + pInfo->num_digits_frac - pInfo->num_digits_omit) ) then
						value = 0.0
					else
						value *= pow( 10.0, -ExpValue + pInfo->num_digits_fix )
					end if
					#else
					value = 0.0
					#endif
					ExpValue = 0
				end if

			/' value is 0.0 or (+|-)1.0... '/
			else
				/' too big to fit on a long long? '/
				if ( ExpValue > FB_MAXFIXLEN ) then
					ExpValue -= FB_MAXFIXLEN
					value *= pow( 10.0, -ExpValue )
				else
					ExpValue = 0
				end if 
			end if

			value = hRound( value, pInfo )

			/' value rounded up to next power of 10? '/
			if ( pInfo->has_exponent andalso (fb_IntLog10_64( cast(ulongint, fabs( value ) ) ) = pInfo->num_digits_fix ) ) then
				value /= 10.0
				ExpValue += 1
				LenExp = sprintf( @ExpPart(0), "%d", cast(long, ExpValue) )
				if( ExpValue < 0 ) then
					IndexExp = 1
					ExpAdjust = 1
				else
					IndexExp = 0
					ExpAdjust = 0
				end if

				NumSkipExp = pInfo->exp_digits - ( LenExp - ExpAdjust )
			end if

			fb_hGetNumberParts( value, @FixPart(0), @LenFix, @FracPart(0), @LenFrac, @chSign, asc("."), pInfo->num_digits_frac )


			/' handle too big numbers '/
			if ( (ExpValue > 0) andalso (pInfo->has_exponent = FALSE) ) then
				dim as long i = 0
				while( i < ExpValue )
					FixPart(LenFix+i) = asc( "0" )
					i += 1
				wend
				LenFix += ExpValue

				FixPart(LenFix) = 0 '' NUL CHAR
			end if

			/' Number of digits to skip on output '/
			NumSkipFix = pInfo->num_digits_fix - LenFix

		end if
	else
		/' just assume the max possible '/
		LenFix = iif(ExpValue > FB_MAXFIXLEN, ExpValue, FB_MAXFIXLEN)
		LenFrac = 0
	end if

	IndexFix = 0 
	IndexFrac = 0
	i = 0
	while( i <> mask_length )
		dim as const ubyte ptr pszAdd = mask + i
		dim as ubyte ptr pszAddFree = NULL
		dim as long LenAdd = 1
		dim as ubyte chCurrent = *pszAdd
		if ( do_skip ) then
			do_skip = FALSE
			if ( do_output = FALSE ) then
				pInfo->length_min += 1
			else
				do_add = TRUE
			end if
		elseif ( do_exp ) then
			if ( do_output = FALSE ) then
				pInfo->has_exponent = TRUE
				select case chCurrent
					case asc("-"):
						pInfo->exponent_add_plus = FALSE
						pInfo->length_opt += 1
					case asc("+"):
						pInfo->exponent_add_plus = TRUE
						pInfo->length_min += 1
					case else:
						fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
						return FALSE
				end select
			else
				if ( pInfo->exponent_add_plus orelse ExpValue < 0 ) then
					if ( ExpValue < 0 ) then
						pszAdd = sadd("-")
					else
						pszAdd = sadd("+")
					end if
					do_add = TRUE
				end if
			end if
			do_exp = FALSE
			did_exp = TRUE
			do_num_frac = FALSE
		elseif ( do_string ) then
			if ( chCurrent = asc(!"\"") ) then
				do_string = FALSE
			elseif ( do_output = FALSE ) then
				pInfo->length_min += 1
			else
				do_add = TRUE
			end if
		else
			if ( do_output ) then
				select case chCurrent
					case asc("."), asc("#"), asc("0"):
						if ( ( pInfo->has_sign = FALSE ) andalso ( did_sign = FALSE ) ) then
							did_sign = TRUE
							if ( pInfo->sign_add_plus orelse chSign=asc("-") ) then
								pszAdd = @chSign
								do_add = TRUE
							else
								continue while
							end if
						elseif ( NumSkipFix < 0 ) then
							DBG_ASSERT( IndexFix <> LenFix )
							pszAdd = @FixPart(0) + IndexFix
							if ( pInfo->has_thousand_sep ) then
								dim as long remaining = LenFix - IndexFix
								if ( IndexFix <> LenFix andalso (remaining mod 3)=0 ) then
									if ( did_thousandsep ) then
										did_thousandsep = FALSE
										LenAdd = 3
									else
										if ( IndexFix >= 1 ) then
											did_thousandsep = TRUE
											pszAdd = @chThousandsSep
											LenAdd = 1
										end if
									end if
								else
									LenAdd = remaining mod 3
								end if
							else
								LenAdd = -NumSkipFix
							end if
							do_add = TRUE
							if ( did_thousandsep = FALSE ) then
								IndexFix += LenAdd
								NumSkipFix += LenAdd
							end if
						end if
				end select
				if ( do_add ) then
					i -= 1
				end if
			end if

			if ( do_add = FALSE  ) then
				select case chCurrent
					case asc("%"), asc(","), asc("#"), asc("0"), asc("+"), asc("E"), asc("e"):
						if ( pInfo->mask_type = eMT_Unknown ) then
							pInfo->mask_type = eMT_Number
						/'
						elseif ( pInfo->mask_type <> eMT_Number ) then
							fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
							return FALSE
						'/
						end if
					case asc("-"), asc("."):
						if ( pInfo->mask_type=eMT_Unknown ) then
							pInfo->mask_type = eMT_Number
						end if
					case asc("d"), asc("n"), asc("m"), asc("M"), asc("y"), asc("h"), asc("H"), asc("s"), asc("t"), asc(":"), asc("/"):
						if ( pInfo->mask_type = eMT_Unknown ) then
							pInfo->mask_type = eMT_DateTime
						/'
						elseif ( pInfo->mask_type <> eMT_DateTime ) then
							fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
							return FALSE
						'/
						end if
				end select


				/' Here comes the real interpretation '/
				select case chCurrent
					case asc("%"):
						if ( do_output = FALSE ) then
							if ( pInfo->mask_type = eMT_Number ) then
								if ( pInfo->has_percent = FALSE ) then
									pInfo->has_percent = TRUE
									pInfo->length_min += 1
								else
									fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
									return FALSE
								end if
							else
								pInfo->length_min += 1
							end if
						else
							do_add = TRUE
						end if
					case asc("."):
						if ( do_output = FALSE ) then
							if ( pInfo->mask_type = eMT_Number ) then
								if ( pInfo->has_decimal_point = FALSE ) then
									pInfo->has_decimal_point = TRUE
									if ( last_was_comma ) then
										pInfo->num_digits_omit += 3
										was_k_div = TRUE
									elseif( pInfo->num_digits_omit <> 0 ) then
										pInfo->num_digits_omit += 3
									end if
								end if
							end if
							pInfo->length_min += 1
						else
							do_add = TRUE
							if ( pInfo->mask_type = eMT_Number ) then
								pszAdd = @chDecimalPoint
							end if
						end if
						do_num_frac = TRUE
					case asc(","):
						if ( do_output = FALSE ) then
							if ( pInfo->mask_type = eMT_Number ) then
								if ( last_was_comma ) then
									pInfo->num_digits_omit += 3
									was_k_div = TRUE
								end if
								last_was_comma = TRUE
							else
								pInfo->length_min += 1
							end if
						else
							if ( pInfo->mask_type = eMT_Number ) then
								if ( last_was_comma ) then
									was_k_div = TRUE
								end if
								last_was_comma = TRUE
							else
								do_add = TRUE
							end if
						end if
					case asc("#"), asc("0"):
						if ( do_output = FALSE ) then
							if ( pInfo->mask_type = eMT_Number ) then
								if ( do_num_frac ) then
									pInfo->num_digits_frac += 1
								elseif ( did_exp ) then
									pInfo->exp_digits += 1
								else
									pInfo->num_digits_fix += 1
								end if
								if ( chCurrent = asc("#") ) then
									pInfo->length_opt += 1
								else
									pInfo->length_min += 1
								end if
							else
								pInfo->length_min += 1
							end if
						else
							if ( pInfo->mask_type = eMT_Number ) then
								if ( do_num_frac ) then
									if ( IndexFrac <> LenFrac ) then
										pszAdd = @FracPart(0) + IndexFrac
										IndexFrac += 1
										do_add = TRUE
									elseif ( chCurrent = asc( "0" ) ) then
										do_add = TRUE
									end if
								elseif ( did_exp ) then
									if ( NumSkipExp > 0 ) then
										if( chCurrent = asc( "0" ) ) then
											do_add = TRUE
										end if
										NumSkipExp -= 1
									elseif( IndexExp <> LenExp ) then
										pszAdd = @ExpPart(0) + IndexExp
										IndexExp += 1
										if ( (IndexExp-ExpAdjust) >= pInfo->exp_digits andalso ( IndexExp <> LenExp ) ) then
											i -= 1
										end if
										do_add = TRUE
									else
										DBG_ASSERT( FALSE )
									end if
								else
									if ( pInfo->has_thousand_sep ) then
										dim as long remaining = LenFix - IndexFix + NumSkipFix
										if ( (remaining mod 3) = 0 ) then
											if ( did_thousandsep ) then
												did_thousandsep = FALSE
											else
												if ( NumSkipFix = 0 andalso IndexFix <> 0 ) then
													did_thousandsep = TRUE
													pszAdd = @chThousandsSep
													LenAdd = 1
													do_add = TRUE
													i -= 1
												end if
											end if
										end if
									end if

									if ( do_add = FALSE ) then
										if ( NumSkipFix ) then
											if ( chCurrent = asc( "0" ) ) then
												do_add = TRUE
											end if
											NumSkipFix -= 1
										else
											if ( IndexFix <> LenFix ) then
												pszAdd = @FixPart(0) + IndexFix
												IndexFix += 1
												do_add = TRUE
											elseif ( chCurrent = asc( "0" ) ) then
												do_add = TRUE
											end if
										end if
									end if
								end if
							else
								do_add = TRUE
							end if
						end if
					case asc("E"), asc("e"):
						if ( pInfo->mask_type = eMT_Number ) then
							if ( did_exp = FALSE ) then
								do_exp = TRUE
								if( do_output = FALSE ) then
									pInfo->length_min += 1
								else
									do_add = TRUE
								end if
							else
								fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
								return FALSE
							end if
						else
							if ( do_output = FALSE ) then
								pInfo->length_min += 1
							else
								do_add = TRUE
							end if
						end if
					case asc(!"\\"):
						do_skip = TRUE
					case asc("*"), asc("$"), asc("("), asc(")"), asc(" "), asc(!"\t"):
						if ( do_output = FALSE ) then
							pInfo->length_min += 1
						else
							do_add = TRUE
						end if
					case asc("+"), asc("-"):
						/' position of the sign? '/
						if ( do_output = FALSE ) then
							pInfo->length_min += 1
							if ( pInfo->has_sign = FALSE ) then
								pInfo->has_sign = TRUE
								pInfo->sign_add_plus = (chCurrent = asc("+") )
							end if
						else
							if ( pInfo->mask_type = eMT_DateTime ) then
								do_add = TRUE
							elseif ( did_sign = FALSE ) then
								did_sign = TRUE
								if ( pInfo->sign_add_plus orelse chSign = asc("-") ) then
									pszAdd = @chSign
									do_add = TRUE
								end if
							else
								do_add = TRUE
							end if
						end if
					case asc("d"), asc("n"), asc("m"), asc("M"), asc("y"), asc("h"), asc("H"), asc("s"), asc("t"):
						/' complete short time '/
						if ( pInfo->mask_type = eMT_DateTime ) then
							dim as long old_did_hour = did_hour
							dim as long count = 1
							while ( mask[i+count] = chCurrent )
								count += 1
							wend
							did_hour = FALSE
							if ( chCurrent = asc("m") ) then
								if ( count > 2 orelse (old_did_hour = FALSE ) ) then
									chCurrent = asc("M")
								end if
							end if
							if ( chCurrent = asc("t") andalso count = 5 ) then
								dim as FBSTRING ptr tmp
								i += (count-1)
								fb_IntlGetTimeFormat( @FixPart(0), ARRAY_SIZEOF(FixPart), FALSE )
								tmp = fb_hStrFormat ( value, @FixPart(0), strlen(@FixPart(0)) )
								if ( do_output = FALSE ) then
									pInfo->length_min += FB_STRSIZE(tmp)
								else
									pszAddFree = strdup( tmp->data )
									LenAdd = FB_STRSIZE( tmp )
									do_add = TRUE
								end if
								fb_hStrDelTemp( tmp )
							elseif ( chCurrent = asc("t") andalso (count = 1 orelse count = 2) ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += count
									pInfo->has_ampm = TRUE
								else
									dim as long _hour = fb_Hour( value )
									if ( _hour >= 12 ) then
										pszAdd = sadd("PM")
									else
										pszAdd = sadd("AM")
									end if
									LenAdd = count
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("d") andalso count = 5 ) then
								dim as FBSTRING ptr tmp
								i += count-1
								fb_IntlGetDateFormat( @FixPart(0), ARRAY_SIZEOF(FixPart), FALSE )
								tmp = fb_hStrFormat ( value, @FixPart(0), strlen(@FixPart(0)) )
								if ( do_output = FALSE ) then
									pInfo->length_min += FB_STRSIZE(tmp)
								else
									pszAddFree = strdup( tmp->data )
									LenAdd = FB_STRSIZE( tmp )
									do_add = TRUE
								end if
								fb_hStrDelTemp( tmp )
							elseif ( chCurrent = asc("d") andalso count = 1 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
									pInfo->length_opt += 1
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0),"%d", fb_Day( value ) )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("d") andalso count = 2 ) then
								i += count - 1
								if ( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%02d", fb_Day( value ) )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("d") andalso (count = 3 orelse count = 4) ) then
								dim as long _weekday = fb_Weekday( value, FB_WEEK_DAY_SUNDAY )
								dim as FBSTRING ptr tmp = fb_WeekdayName( _weekday, (count = 3), FB_WEEK_DAY_SUNDAY )
								i += count - 1
								if ( do_output = FALSE ) then
									pInfo->length_min += FB_STRSIZE( tmp )
								else
									pszAddFree = strdup( tmp->data )
									LenAdd = 0
									do_add = TRUE
								end if
								fb_hStrDelTemp( tmp )
							elseif ( (chCurrent = asc("m") orelse chCurrent = asc("n") ) andalso count = 1 ) then
								i += count - 1
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
									pInfo->length_opt += 1
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%d", fb_Minute( value ) )
									do_add = TRUE
								end if
							elseif ( (chCurrent = asc("m") orelse chCurrent = asc("n")) andalso count = 2 ) then
								i += count-1
								if( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%02d", fb_Minute( value ) )
									do_add = TRUE
								end if
							elseif ( (chCurrent = asc("h") orelse chCurrent = asc("H")) andalso count = 1 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
									pInfo->length_opt += 1
								else
									dim as long _hour = fb_Hour( value )
									if ( pInfo->has_ampm and chCurrent = asc("h") ) then
										if ( _hour > 12 ) then
											_hour -= 12
										elseif ( _hour = 0 ) then
											_hour += 12
										end if
									end if
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%d", _hour )
									do_add = TRUE
								end if
								did_hour = TRUE
							elseif ( (chCurrent = asc("h") orelse chCurrent = asc("H")) andalso count = 2 ) then
								i += count-1
								if( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									dim as long _hour = fb_Hour( value )
									if ( pInfo->has_ampm and chCurrent = asc("h") ) then
										if ( _hour > 12 ) then
											_hour -= 12
										elseif ( _hour = 0 ) then
											_hour += 12
										end if
									end if
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%02d", _hour )
									do_add = TRUE
								end if
								did_hour = TRUE
							elseif ( chCurrent = asc("s") andalso count = 1 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
									pInfo->length_opt += 1
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%d", fb_Second( value ) )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("s") andalso count = 2 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%02d", fb_Second( value ) )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("M") andalso count = 1 ) then
								i += count-1
								if( do_output = FALSE ) then
									pInfo->length_min += 1
									pInfo->length_opt += 1
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%d", fb_Month( value ) )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("M") andalso count = 2 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%02d", fb_Month( value ) )
									do_add = TRUE
								end if
							elseif( chCurrent = asc("M") andalso (count = 3 orelse count = 4) ) then
								dim as long _month = fb_Month( value )
								dim as FBSTRING ptr tmp = fb_MonthName( _month, (count = 3) )
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += FB_STRSIZE( tmp )
								else
									pszAddFree = strdup( tmp->data )
									LenAdd = 0
									do_add = TRUE
								end if
								fb_hStrDelTemp( tmp )
							elseif ( chCurrent = asc("y") andalso count < 3 ) then
								i += count-1
								if( do_output = FALSE ) then
									pInfo->length_min += 2
								else
									pszAdd = @FixPart(0)
									dim as long tmp = fb_Year( value ) mod 100  'See #874
									LenAdd = sprintf( @FixPart(0), "%02d", tmp )
									do_add = TRUE
								end if
							elseif ( chCurrent = asc("y") andalso count = 4 ) then
								i += count-1
								if ( do_output = FALSE ) then
									pInfo->length_min += 4
								else
									pszAdd = @FixPart(0)
									LenAdd = sprintf( @FixPart(0), "%04d", fb_Year( value ) )
									do_add = TRUE
								end if
							else
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
								else
									do_add = TRUE
								end if
							end if
						else
							if ( do_output = FALSE ) then
								pInfo->length_min += 1
							else
								do_add = TRUE
							end if
						end if
					case asc("/"):
						/' date divider '/
						if ( do_output = FALSE ) then
							pInfo->length_min += 1
						else
							if ( pInfo->mask_type = eMT_DateTime ) then
								pszAdd = @chDateSep
							end if
							do_add = TRUE
						end if
					case asc(":"):
						/' time divider '/
						if ( do_output = FALSE ) then
							pInfo->length_min += 1
						else
							if ( pInfo->mask_type = eMT_DateTime ) then
								pszAdd = @chTimeSep
							end if
							do_add = TRUE
						end if
					case asc("a"), asc("A"):
						/' AM/PM or A/P (in any combination of cases) '/
						if ( pInfo->mask_type = eMT_DateTime ) then
							if ( (strncasecmp( mask+i, "AM/PM", 5 ) = 0) orelse strncasecmp( mask+i, "A/P", 3 ) = 0) then
								if ( do_output = FALSE ) then
									if ( pInfo->mask_type = eMT_Unknown ) then
										pInfo->mask_type = eMT_DateTime
									elseif ( pInfo->mask_type <> eMT_DateTime ) then
										fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
										return FALSE
									end if
									pInfo->has_ampm = TRUE
								else
									dim as long ampm_small = (mask[i+1] = asc("/"))
									LenAdd = iif( ampm_small, 1, 2 )
									if ( fb_Hour( value ) >= 12 ) then
										pszAdd = mask + i + LenAdd + 1
									else
										pszAdd = mask + i
									end if
									do_add = TRUE
								end if
								i += iif(mask[i+1] = asc("/"), 2, 4)
							else
								if ( do_output = FALSE ) then
									pInfo->length_min += 1
								else
									do_add = TRUE
								end if
							end if
						else
							if ( do_output = FALSE ) then
								pInfo->length_min += 1
							else
								do_add = TRUE
							end if
						end if
					case asc(!"\""):
						do_string = TRUE
					case else:
						if ( do_output = FALSE ) then
							pInfo->length_min += 1
						else
							do_add = TRUE
						end if
				end select
			end if
		end if
		if ( (last_was_comma <> FALSE) andalso (chCurrent <> 44 orelse i = (mask_length - 1)) ) then
			if( (do_output = FALSE) andalso (was_k_div = FALSE ) ) then
				pInfo->has_thousand_sep = TRUE
			end if
			last_was_comma = FALSE
			was_k_div = FALSE
		end if
		if ( do_add ) then
			do_add = FALSE
			DBG_ASSERT(do_output)
			DBG_ASSERT(pszOut <> NULL)
			if ( pszAddFree <> NULL ) then
				pszAdd = pszAddFree
			end if
			if ( LenAdd = 0 ) then
				LenAdd = strlen( pszAdd )
			end if
			DBG_ASSERT(LenOut>=LenAdd)
			FB_MEMCPY( pszOut, pszAdd, LenAdd )
			pszOut += LenAdd
			LenOut -= LenAdd
			if ( pszAddFree <> NULL ) then
				free( pszAddFree )
			end if
		end if
		i += 1
	wend

	if ( do_output = FALSE ) then
		if ( pInfo->has_decimal_point = FALSE ) then
			if ( pInfo->num_digits_omit <> 0 ) then
				pInfo->num_digits_omit += 3
			end if
		end if
		if ( pInfo->has_thousand_sep ) then
			pInfo->length_min += (pInfo->num_digits_fix - 1) / 3
		end if
		if ( LenFix > pInfo->num_digits_fix ) then
			pInfo->length_min += LenFix - pInfo->num_digits_fix
		end if
		if ( pInfo->exp_digits < 5 ) then
			pInfo->length_opt += 5 - pInfo->exp_digits
		end if
		if ( pInfo->has_sign = FALSE ) then
			pInfo->length_min += 1
		end if
	else
		DBG_ASSERT( LenOut>=0 )
		*pszOut = 0
		fb_hStrSetLength( dst, pszOut - dst->data )
	end if

	return TRUE
end function

function fb_hStrFormat FBCALL ( value as double, mask as const ubyte ptr, mask_length as size_t ) as FBSTRING ptr
	dim as FBSTRING ptr dst = @__fb_ctx.null_desc
	dim as const ubyte ptr pszIntlResult
	dim as ubyte chDecimalPoint, chThousandsSep, chDateSep, chTimeSep

	fb_ErrorSetNum( FB_RTERROR_OK )

	FB_LOCK()
	pszIntlResult = fb_IntlGet( eFIL_NumDecimalPoint, FALSE )
	chDecimalPoint = iif(( pszIntlResult = NULL ), asc("."), *pszIntlResult )
	pszIntlResult = fb_IntlGet( eFIL_NumThousandsSeparator, FALSE )
	chThousandsSep = iif(( pszIntlResult = NULL ), asc(","), *pszIntlResult )
	pszIntlResult = fb_IntlGet( eFIL_DateDivider, FALSE )
	chDateSep = iif(( pszIntlResult = NULL ), asc("/"), *pszIntlResult )
	pszIntlResult = fb_IntlGet( eFIL_TimeDivider, FALSE )
	chTimeSep = iif(( pszIntlResult = NULL ), asc(":"), *pszIntlResult )
	FB_UNLOCK()

	if ( chDecimalPoint = 0 ) then
		chDecimalPoint = asc(".")
	end if
	if ( chThousandsSep = 0 ) then
		chThousandsSep = asc(",")
	end if

	FB_STRLOCK()

	if ( mask = NULL orelse mask_length = 0 ) then
		dst = fb_hBuildDouble( value, chDecimalPoint, 0 )
	else 
		dim as FormatMaskInfo info

		/' Extract all information from the mask string '/
		if ( fb_hProcessMask( NULL, mask, mask_length, value, @info, chThousandsSep, chDecimalPoint, chDateSep, chTimeSep ) ) then
			dst = fb_hStrAllocTemp_NoLock( NULL, info.length_min + info.length_opt )
			if ( dst = NULL ) then
				fb_ErrorSetNum( FB_RTERROR_OUTOFMEM )
				dst = @__fb_ctx.null_desc
			else
				/' Build the new string according to the mask '/
				fb_hProcessMask( dst, mask, mask_length, value, @info, chThousandsSep, chDecimalPoint, chDateSep, chTimeSep )
			end if
		end if
	end if

	FB_STRUNLOCK()

	return dst
end function

function fb_StrFormat FBCALL ( value as double, mask as FBSTRING ptr ) as FBSTRING ptr
	dim as FBSTRING ptr dst

	dst = fb_hStrFormat( value, mask->data, FB_STRSIZE(mask) )

	/' del if temp '/
	fb_hStrDelTemp( mask )

	return dst
end function
end extern
