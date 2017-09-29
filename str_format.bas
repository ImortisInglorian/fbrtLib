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

    as integer has_decimal_point
    as integer has_thousand_sep
    as integer has_percent
    as integer has_exponent
    as integer exponent_add_plus
    as integer has_sign
    as integer sign_add_plus
    as integer num_digits_fix
    as integer num_digits_frac
    as integer num_digits_omit
    as integer exp_digits

    as integer has_ampm

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
sub fb_hGetNumberParts cdecl ( number as double, pachFixPart as ubyte ptr, pcchLenFix as ssize_t ptr, pachFracPart as ubyte ptr, pcchLenFrac as ssize_t ptr, pchSign as ubyte ptr, chDecimalPoint as ubyte, precision as integer )
    dim as ubyte ptr pszFracStart, pszFracEnd
    dim as ubyte chSign
    dim as double dblFix
    dim as double dblFrac = modf( number, @dblFix )
    dim as integer neg = (number < 0.0)
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
    if ( *pszFracStart = sadd("-") ) then
        pszFracStart += 1       /' Required for -0.0 value '/
	end if
    pszFracStart += 1
    pszFracEnd = pachFracPart + len_frac
    while ( pszFracEnd <> pszFracStart )
        pszFracEnd -= 1
        if ( *pszFracEnd <> sadd("0") ) then
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
    if ( ullFix=0 and neg ) then
        pachFixPart[0] = 0
        len_fix = 0
        chSign = 45
    elseif ( ullFix=0 and number > 0.0 ) then
        pachFixPart[0] = 0
        len_fix = 0
        chSign = 43
    else
        if ( neg ) then
            chSign = 45
        elseif ( ullFix > 0 ) then
            chSign = 43
        else
            chSign = 0
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

function fb_hBuildDouble cdecl ( num as double, decimal_point as ubyte, thousands_separator as ubyte ) as FBSTRING ptr
    dim as ubyte FixPart(0 to 127), FracPart(0 to 127), chSign
    dim as ssize_t LenFix, LenFrac, LenSign, LenDecPoint, LenTotal
    dim as FBSTRING ptr dst

    fb_hGetNumberParts( num, @FixPart(0), @LenFix, @FracPart(0), @LenFrac, @chSign, 46, 11 )

    LenSign = iif( chSign = 45, 1, 0 )
    LenDecPoint = iif( LenFrac <> 0, 1, 0 )
    LenTotal = LenSign + LenFix + LenDecPoint + LenFrac

	/' alloc temp string '/
    dst = fb_hStrAllocTemp_NoLock( NULL, LenTotal )
	if ( dst <> NULL ) then
        if ( LenSign <> 0 ) then
            dst->_data[0] = chSign
        end if
        FB_MEMCPY( dst->_data + LenSign, @FixPart(0), LenFix )
        if ( LenDecPoint <> 0 ) then
            dst->_data[LenSign + LenFix] = decimal_point
        end if
        FB_MEMCPY( dst->_data + LenSign + LenFix + LenDecPoint, @FracPart(0), LenFrac )
        dst->_data[LenTotal] = 0
	else
		dst = @__fb_ctx.null_desc
	end if
	
	return dst
end function

function hRound cdecl ( value as double, pInfo as FormatMaskInfo const ptr ) as double
	dim as double _fix, _frac = modf( value, @_fix )

    if ( pInfo->num_digits_frac = 0 ) then
    	/' round it here, because modf() at GetNumParts won't '/

    	/' convert to fixed-point because the imprecision and the optimizations
    	   that can be done by gcc (ie: keeping values on fpu stack as twords) '/
    	dim as longint intfrac = cast(longint, _frac * 1.E + 15)
    	if ( intfrac > cast(longint, 5.E + 14) ) then
        	value = ceil( value )
		elseif( intfrac < -cast(longint, 5.E + 14) ) then
        	value = floor( value )
		end if
	else
		/' remove the fraction of the fraction to be compatible with
		   VBDOS (ie: 2.55 -> 2.5, not 2.6 as in VB6) '/
		if ( _frac <> 0.0 ) then
	    	dim as double p10 = pow( 10.0, pInfo->num_digits_frac )

	        dim as double fracfrac = modf( _frac * p10, @_frac )

	        /' convert to fixed-point, see above '/
	        dim as longint intfrac = cast(longint, fracfrac * (1.E + 15 / p10) )

	        if ( intfrac > cast(longint, 5.E + 14 / p10) ) then
	        	_frac += 1.0
	        elseif ( intfrac < -cast(longint, 5.E + 14 / p10) ) then
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
function fb_hProcessMask cdecl ( dst as FBSTRING ptr, mask as ubyte const ptr, mask_length as ssize_t, value as double, pInfo as FormatMaskInfo ptr, chThousandsSep as ubyte, chDecimalPoint as ubyte, chDateSep as ubyte, chTimeSep as ubyte ) as integer
    dim as ubyte FixPart(0 to 127), FracPart(0 to 127), ExpPart(0 to 127), chSign = 0
    dim as ssize_t LenFix, LenFrac, LenExp = 0, IndexFix, IndexFrac, IndexExp = 0
    dim as ssize_t ExpValue, ExpAdjust = 0, NumSkipFix = 0, NumSkipExp = 0
    dim as integer do_skip = FALSE, do_exp = FALSE, do_string = FALSE
    dim as integer did_sign = FALSE, did_exp = FALSE, did_hour = FALSE, did_thousandsep = FALSE
    dim as integer do_num_frac = FALSE, last_was_comma = FALSE, was_k_div = FALSE
    dim as integer do_output = (dst <> NULL)
    dim as integer do_add = FALSE
    dim as ssize_t LenOut
    dim as ubyte ptr pszOut
    dim as ssize_t i

    DBG_ASSERT( pInfo <> NULL )

    if ( not(do_output) ) then
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
        pszOut = dst->_data
        LenOut = FB_STRSIZE( dst )
    end if

	if ( value <> 0.0 ) then
		ExpValue = cast(integer ,floor( log10( fabs( value ) ) ) + 1)
	else
		ExpValue = 0
	end if
	
    if ( do_output ) then
        if ( pInfo->mask_type = eMT_Number ) then
            /' When output of exponent is required, shift value to the
             * left (* 10^n) as far as possible. "As far as possible" depends
             * on the number of digits required by the number as a textual
             * representation. '/

			if ( pInfo->has_exponent ) then
				/' exponent too big? scale (up or down) '/
				if ( ExpValue <= 0 ) then
					ExpValue -= pInfo->num_digits_fix
				else
					if ( pInfo->num_digits_frac > 0 ) then
						if ( ExpValue > pInfo->num_digits_fix ) then
							ExpValue -= pInfo->num_digits_fix
						else
							ExpValue = 0
						end if
					else
						if ( ExpValue > FB_MAXFIXLEN ) then
							ExpValue -= FB_MAXFIXLEN
						else
							ExpValue = 0
						end if
					end if
				end if

				if ( ExpValue <> 0 ) then
					if ( -ExpValue <= 308 ) then
						value *= pow( 10.0, -ExpValue )
					else
						value *= pow( 5.0, -ExpValue )
						value *= pow( 2.0, -ExpValue )
					end if
				end if

				LenExp = sprintf( @ExpPart(0), "%d", cast(integer, ExpValue) )

	            if ( ExpValue < 0 ) then
					IndexExp = ExpAdjust = 1
				else
					IndexExp = ExpAdjust = 0
				end if
				NumSkipExp = pInfo->exp_digits - ( LenExp - ExpAdjust )
			/' value between (+|-)0.0..1.0 '/
			elseif ( ExpValue < 0 ) then
				/' too small? '/
				if ( -ExpValue >= pInfo->num_digits_frac ) then
					#if 0
					/' can't scale? '/
					if ( (pInfo->num_digits_frac == 0 ) or (-ExpValue > pInfo->num_digits_fix + pInfo->num_digits_frac - pInfo->num_digits_omit) ) then
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
				endif 
			end if

			value = hRound( value, pInfo )

			/' value rounded up to next power of 10? '/
			if ( pInfo->has_exponent and (fb_IntLog10_64( cast(ulongint, fabs( value ) ) = pInfo->num_digits_fix) ) ) then
				value /= 10.0
				ExpValue += 1
				LenExp = sprintf( @ExpPart(0), "%d", cast(integer, ExpValue) )
				if( ExpValue < 0 ) then
					IndexExp = ExpAdjust = 1
				else
					IndexExp = ExpAdjust = 0
				end if

				NumSkipExp = pInfo->exp_digits - ( LenExp - ExpAdjust )
			end if

			fb_hGetNumberParts( value, @FixPart(0), @LenFix, @FracPart(0), @LenFrac, @chSign, 46, pInfo->num_digits_frac )


			/' handle too big numbers '/
			if ( (ExpValue > 0) and not(pInfo->has_exponent) ) then
				dim as integer i
				for i = 0 to ExpValue
					FixPart(LenFix+i) = 0
				next
				LenFix += ExpValue

				FixPart(LenFix) = 0
			end if

			/' Number of digits to skip on output '/
            NumSkipFix = pInfo->num_digits_fix - LenFix

        end if
    else
		/' just assume the max possible '/
		LenFix = iif(ExpValue > FB_MAXFIXLEN, ExpValue, FB_MAXFIXLEN)
		LenFrac = 0
    end if

    IndexFix = (IndexFrac = 0)
    for i = 0 to mask_length - 1
        dim as ubyte ptr pszAdd = mask + i
        dim as ubyte ptr pszAddFree = NULL
        dim as integer LenAdd = 1
        dim as ubyte chCurrent = *pszAdd
        if ( do_skip ) then
            do_skip = FALSE
            if ( not(do_output) ) then
                pInfo->length_min += 1
            else
                do_add = TRUE
            end if
        elseif ( do_exp ) then
            if ( not(do_output) ) then
                pInfo->has_exponent = TRUE
                select case chCurrent
					case 45:
						pInfo->exponent_add_plus = FALSE
						pInfo->length_opt += 1
					case 43:
						pInfo->exponent_add_plus = TRUE
                    pInfo->length_min += 1
					case else:
						fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
						return FALSE
                end select
            else
                if ( pInfo->exponent_add_plus or ExpValue < 0 ) then
                    if ( ExpValue < 0 ) then
                        pszAdd = 43
                    else
                        pszAdd = 43
                    end if
                    do_add = TRUE;
                end if
            end if
            do_exp = FALSE
            did_exp = TRUE
            do_num_frac = FALSE
        elseif ( do_string ) then
            if ( chCurrent = 34 ) then
                do_string = FALSE
            elseif ( not(do_output) ) then
                pInfo->length_min += 1
            else
                do_add = TRUE
            end if
        else
            if ( do_output ) then
				'-------------------------Start Here-----------------------------
                switch (chCurrent ) {
                case '.':
                case '#':
                case '0':
                    if( !pInfo->has_sign && !did_sign ) {
                        did_sign = TRUE;
                        if( pInfo->sign_add_plus || chSign=='-' ) {
                            pszAdd = &chSign;
                            do_add = TRUE;
                        } else {
                            --i;
                            continue;
                        }
                    } else if( NumSkipFix < 0 ) {
                        DBG_ASSERT( IndexFix!=LenFix );
                        pszAdd = FixPart + IndexFix;
                        if( pInfo->has_thousand_sep ) {
                            int remaining = LenFix - IndexFix;
                            if( IndexFix != LenFix && (remaining % 3)==0 ) {
                                if( did_thousandsep ) {
                                    did_thousandsep = FALSE;
                                    LenAdd = 3;
                                } else {
                                    if( IndexFix >= 1 ) {
                                        did_thousandsep = TRUE;
                                        pszAdd = &chThousandsSep;
                                        LenAdd = 1;
                                    }
                                }
                            } else {
                                LenAdd = remaining % 3;
                            }
                        } else {
                            LenAdd = -NumSkipFix;
                        }
                        do_add = TRUE;
                        if( !did_thousandsep ) {
                            IndexFix += LenAdd;
                            NumSkipFix += LenAdd;
                        }
                    }
                    break;
                }
                if( do_add )
                    --i;
            end if

            if( !do_add ) {
                switch( chCurrent ) {
                case '%':
                case ',':
                case '#':
                case '0':
                case '+':
                case 'E':
                case 'e':
                    if( pInfo->mask_type==eMT_Unknown ) {
                        pInfo->mask_type = eMT_Number;
#if 0
                    } else if( pInfo->mask_type!=eMT_Number ) {
                        fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
                        return FALSE;
#endif
                    }
                    break;
                case '-':
                case '.':
                    if( pInfo->mask_type==eMT_Unknown ) {
                        pInfo->mask_type = eMT_Number;
                    }
                    break;
                case 'd':
                case 'n':
                case 'm':
                case 'M':
                case 'y':
                case 'h':
                case 'H':
                case 's':
                case 't':
                case ':':
                case '/':
                    if( pInfo->mask_type==eMT_Unknown ) {
                        pInfo->mask_type = eMT_DateTime;
#if 0
                    } else if( pInfo->mask_type!=eMT_DateTime ) {
                        fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
                        return FALSE;
#endif
                    }
                    break;
                }


                /* Here comes the real interpretation */
                switch( chCurrent ) {
                case '%':
                    if( !do_output ) {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( !pInfo->has_percent ) {
                                pInfo->has_percent = TRUE;
                                ++pInfo->length_min;
                            } else {
                                fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
                                return FALSE;
                            }
                        } else {
                            ++pInfo->length_min;
                        }
                    } else {
                        do_add = TRUE;
                    }
                    break;
                case '.':
                    if( !do_output ) {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( !pInfo->has_decimal_point ) {
                                pInfo->has_decimal_point = TRUE;
                                if( last_was_comma ) {
                                    pInfo->num_digits_omit += 3;
                                    was_k_div = TRUE;
                                } else if( pInfo->num_digits_omit!=0 ) {
                                    pInfo->num_digits_omit += 3;
                                }
                            }
                        }
                        ++pInfo->length_min;
                    } else {
                        do_add = TRUE;
                        if( pInfo->mask_type==eMT_Number ) {
                            pszAdd = &chDecimalPoint;
                        }
                    }
                    do_num_frac = TRUE;
                    break;
                case ',':
                    if( !do_output ) {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( last_was_comma ) {
                                pInfo->num_digits_omit += 3;
                                was_k_div = TRUE;
                            }
                            last_was_comma = TRUE;
                        } else {
                            ++pInfo->length_min;
                        }
                    } else {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( last_was_comma ) {
                                was_k_div = TRUE;
                            }
                            last_was_comma = TRUE;
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case '#':
                case '0':
                    if( !do_output ) {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( do_num_frac ) {
                                ++pInfo->num_digits_frac;
                            } else if( did_exp ) {
                                ++pInfo->exp_digits;
                            } else {
                                ++pInfo->num_digits_fix;
                            }
                            if( chCurrent=='#' ) {
                                ++pInfo->length_opt;
                            } else {
                                ++pInfo->length_min;
                            }
                        } else {
                            ++pInfo->length_min;
                        }
                    } else {
                        if( pInfo->mask_type==eMT_Number ) {
                            if( do_num_frac ) {
                                if( IndexFrac!=LenFrac ) {
                                    pszAdd = FracPart + IndexFrac++;
                                    do_add = TRUE;
                                } else if( chCurrent=='0' ) {
                                    do_add = TRUE;
                                }
                            } else if( did_exp ) {
                                if( NumSkipExp > 0 ) {
                                    if( chCurrent=='0' ) {
                                        do_add = TRUE;
                                    }
                                    --NumSkipExp;
                                } else if( IndexExp!=LenExp ) {
                                    pszAdd = ExpPart + IndexExp++;
                                    if( (IndexExp-ExpAdjust)>=pInfo->exp_digits
                                        && ( IndexExp!=LenExp ) )
                                    {
                                        --i;
                                    }
                                    do_add = TRUE;
                                } else {
                                    DBG_ASSERT( FALSE );
                                }

                            } else {
                                if( pInfo->has_thousand_sep ) {
                                    int remaining = LenFix - IndexFix + NumSkipFix;
                                    if( (remaining % 3)==0 ) {
                                        if( did_thousandsep ) {
                                            did_thousandsep = FALSE;
                                        } else {
                                            if( NumSkipFix==0 && IndexFix!=0 ) {
                                                did_thousandsep = TRUE;
                                                pszAdd = &chThousandsSep;
                                                LenAdd = 1;
                                                do_add = TRUE;
                                                --i;
                                            }
                                        }
                                    }
                                }

                                if( !do_add ) {
                                    if( NumSkipFix ) {
                                        if( chCurrent=='0' )
                                            do_add = TRUE;
                                        --NumSkipFix;
                                    } else {
                                        if( IndexFix!=LenFix ) {
                                            pszAdd = FixPart + IndexFix++;
                                            do_add = TRUE;
                                        } else if( chCurrent=='0' ) {
                                            do_add = TRUE;
                                        }
                                    }
                                }
                            }
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case 'E':
                case 'e':
                    if( pInfo->mask_type==eMT_Number ) {
                        if( !did_exp ) {
                            do_exp = TRUE;
                            if( !do_output ) {
                                ++pInfo->length_min;
                            } else {
                                do_add = TRUE;
                            }
                        } else {
                            fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
                            return FALSE;
                        }
                    } else {
                        if( !do_output ) {
                            ++pInfo->length_min;
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case '\\':
                    do_skip = TRUE;
                    break;
                case '*':
                case '$':
                case '(':
                case ')':
                case ' ':
                case '\t':
                    if( !do_output ) {
                        ++pInfo->length_min;
                    } else {
                        do_add = TRUE;
                    }
                    break;
                case '+':
                case '-':
                    /* position of the sign? */
                    if( !do_output ) {
                        ++pInfo->length_min;
                        if( !pInfo->has_sign ) {
                            pInfo->has_sign = TRUE;
                            pInfo->sign_add_plus = chCurrent=='+';
                        }
                    } else {
                        if( pInfo->mask_type == eMT_DateTime ) {
                            do_add = TRUE;
                        } else if( !did_sign ) {
                            did_sign = TRUE;
                            if( pInfo->sign_add_plus || chSign=='-' ) {
                                pszAdd = &chSign;
                                do_add = TRUE;
                            }
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case 'd':
                    /* day */
                case 'm':
                    /* minute or month */
                case 'n':
                    /* minute */
                case 'M':
                    /* month */
                case 'y':
                    /* year */
                case 'h':
                case 'H':
                    /* hour */
                case 's':
                    /* second */
                case 't':
                    /* complete short time */
                    if( pInfo->mask_type==eMT_DateTime ) {
                        int old_did_hour = did_hour;
                        int count = 1;
                        while( mask[i+count]==chCurrent )
                            ++count;
                        did_hour = FALSE;
                        if( chCurrent=='m' ) {
                            if( count>2 || !old_did_hour ) {
                                chCurrent = 'M';
                            }
                        }
                        if( chCurrent=='t' && count==5 ) {
                            FBSTRING *tmp;
                            i += count-1;
                            fb_IntlGetTimeFormat( FixPart, sizeof(FixPart), FALSE );
                            tmp = fb_hStrFormat ( value,
                                                  FixPart,
                                                  strlen(FixPart) );
                            if( !do_output ) {
                                pInfo->length_min += FB_STRSIZE(tmp);
                            } else {
                                pszAddFree = strdup( tmp->data );
                                LenAdd = FB_STRSIZE( tmp );
                                do_add = TRUE;
                            }
                            fb_hStrDelTemp( tmp );
                        } else if( chCurrent=='t' && (count==1 || count==2) ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += count;
                                pInfo->has_ampm = TRUE;
                            } else {
                                int hour = fb_Hour( value );
                                if( hour >= 12 ) {
                                    pszAdd = "PM";
                                } else {
                                    pszAdd = "AM";
                                }
                                LenAdd = count;
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='d' && count==5 ) {
                            FBSTRING *tmp;
                            i += count-1;
                            fb_IntlGetDateFormat( FixPart, sizeof(FixPart), FALSE );
                            tmp = fb_hStrFormat ( value,
                                                  FixPart,
                                                  strlen(FixPart) );
                            if( !do_output ) {
                                pInfo->length_min += FB_STRSIZE(tmp);
                            } else {
                                pszAddFree = strdup( tmp->data );
                                LenAdd = FB_STRSIZE( tmp );
                                do_add = TRUE;
                            }
                            fb_hStrDelTemp( tmp );
                        } else if( chCurrent=='d' && count==1 ) {
                            i += count-1;
                            if( !do_output ) {
                                ++pInfo->length_min;
                                ++pInfo->length_opt;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%d",
                                                  fb_Day( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='d' && count==2 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  fb_Day( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='d' && (count==3 || count==4) ) {
                            int weekday = fb_Weekday( value, FB_WEEK_DAY_SUNDAY );
                            FBSTRING *tmp = fb_WeekdayName( weekday, (count==3), FB_WEEK_DAY_SUNDAY );
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += FB_STRSIZE( tmp );
                            } else {
                                pszAddFree = strdup( tmp->data );
                                LenAdd = 0;
                                do_add = TRUE;
                            }
                            fb_hStrDelTemp( tmp );
                        } else if( (chCurrent=='m' || chCurrent == 'n') && count==1 ) {
                            i += count-1;
                            if( !do_output ) {
                                ++pInfo->length_min;
                                ++pInfo->length_opt;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%d",
                                                  fb_Minute( value ) );
                                do_add = TRUE;
                            }
                        } else if( (chCurrent=='m' || chCurrent == 'n') && count==2 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  fb_Minute( value ) );
                                do_add = TRUE;
                            }
                        } else if( (chCurrent=='h' || chCurrent=='H') && count==1 ) {
                            i += count-1;
                            if( !do_output ) {
                                ++pInfo->length_min;
                                ++pInfo->length_opt;
                            } else {
                                int hour = fb_Hour( value );
                                if( pInfo->has_ampm && chCurrent=='h') {
                                    if( hour > 12 ) {
                                        hour -= 12;
                                    } else if( hour==0 ) {
                                        hour += 12;
                                    }
                                }
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%d",
                                                  hour );
                                do_add = TRUE;
                            }
                            did_hour = TRUE;
                        } else if( (chCurrent=='h' || chCurrent=='H') && count==2 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                int hour = fb_Hour( value );
                                if( pInfo->has_ampm && chCurrent=='h' ) {
                                    if( hour > 12 ) {
                                        hour -= 12;
                                    } else if( hour==0 ) {
                                        hour += 12;
                                    }
                                }
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  hour );
                                do_add = TRUE;
                            }
                            did_hour = TRUE;
                        } else if( chCurrent=='s' && count==1 ) {
                            i += count-1;
                            if( !do_output ) {
                                ++pInfo->length_min;
                                ++pInfo->length_opt;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%d",
                                                  fb_Second( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='s' && count==2 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  fb_Second( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='M' && count==1 ) {
                            i += count-1;
                            if( !do_output ) {
                                ++pInfo->length_min;
                                ++pInfo->length_opt;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%d",
                                                  fb_Month( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='M' && count==2 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  fb_Month( value ) );
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='M' && (count==3 || count==4) ) {
                            int month = fb_Month( value );
                            FBSTRING *tmp = fb_MonthName( month, (count==3) );
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += FB_STRSIZE( tmp );
                            } else {
                                pszAddFree = strdup( tmp->data );
                                LenAdd = 0;
                                do_add = TRUE;
                            }
                            fb_hStrDelTemp( tmp );
                        } else if( chCurrent=='y' && count<3 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 2;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%02d",
                                                  fb_Year( value ) % 100);
                                do_add = TRUE;
                            }
                        } else if( chCurrent=='y' && count==4 ) {
                            i += count-1;
                            if( !do_output ) {
                                pInfo->length_min += 4;
                            } else {
                                LenAdd = sprintf( ((pszAdd = FixPart), FixPart),
                                                  "%04d",
                                                  fb_Year( value ));
                                do_add = TRUE;
                            }
                        } else {
                            if( !do_output ) {
                                ++pInfo->length_min;
                            } else {
                                do_add = TRUE;
                            }
                        }
                    } else {
                        if( !do_output ) {
                            ++pInfo->length_min;
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case '/':
                    /* date divider */
                    if( !do_output ) {
                        ++pInfo->length_min;
                    } else {
                        if( pInfo->mask_type==eMT_DateTime ) {
                            pszAdd = &chDateSep;
                        }
                        do_add = TRUE;
                    }
                    break;
                case ':':
                    /* time divider */
                    if( !do_output ) {
                        ++pInfo->length_min;
                    } else {
                        if( pInfo->mask_type==eMT_DateTime ) {
                            pszAdd = &chTimeSep;
                        }
                        do_add = TRUE;
                    }
                    break;
                case 'a':
                case 'A':
                    /* AM/PM or A/P (in any combination of cases) */
                    if( pInfo->mask_type==eMT_DateTime ) {
                        if( (strncasecmp( mask+i, "AM/PM", 5 )==0)
                            || (strncasecmp( mask+i, "A/P", 3 )==0) )
                        {
                            if( !do_output ) {
                                if( pInfo->mask_type==eMT_Unknown ) {
                                    pInfo->mask_type = eMT_DateTime;
                                } else if( pInfo->mask_type!=eMT_DateTime ) {
                                    fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL );
                                    return FALSE;
                                }
                                pInfo->has_ampm = TRUE;
                            } else {
                                int ampm_small = mask[i+1]=='/';
                                LenAdd = ( ampm_small ? 1 : 2 );
                                if( fb_Hour( value ) >= 12 ) {
                                    pszAdd = mask + i + LenAdd + 1;
                                } else {
                                    pszAdd = mask + i;
                                }
                                do_add = TRUE;
                            }
                            i += ((mask[i+1]=='/') ? 2 : 4);
                        } else {
                            if( !do_output ) {
                                ++pInfo->length_min;
                            } else {
                                do_add = TRUE;
                            }
                        }
                    } else {
                        if( !do_output ) {
                            ++pInfo->length_min;
                        } else {
                            do_add = TRUE;
                        }
                    }
                    break;
                case '"':
                    do_string = TRUE;
                    break;
                default:
                    if( !do_output ) {
                        ++pInfo->length_min;
                    } else {
                        do_add = TRUE;
                    }
                    break;
                }
            end if
        end if
        if( last_was_comma && (chCurrent!=',' || i==(mask_length-1)) ) {
            if( !do_output && !was_k_div ) {
                pInfo->has_thousand_sep = TRUE;
            }
            last_was_comma = FALSE;
            was_k_div = FALSE;
        end if
        if( do_add ) {
            do_add = FALSE;
            DBG_ASSERT(do_output);
            DBG_ASSERT(pszOut!=NULL);
            if( pszAddFree!=NULL )
                pszAdd = pszAddFree;
            if( LenAdd==0 )
                LenAdd = strlen( pszAdd );
            DBG_ASSERT(LenOut>=LenAdd);
            FB_MEMCPY( pszOut, pszAdd, LenAdd );
            pszOut += LenAdd;
            LenOut -= LenAdd;
            if( pszAddFree!=NULL ) {
                free( pszAddFree );
            }
        end if
    next

    if ( !do_output ) {
        if( !pInfo->has_decimal_point ) {
            if( pInfo->num_digits_omit!=0 ) {
                pInfo->num_digits_omit += 3;
            }
        }
        if( pInfo->has_thousand_sep ) {
            pInfo->length_min += (pInfo->num_digits_fix - 1) / 3;
        }
        if( LenFix > pInfo->num_digits_fix )
            pInfo->length_min += LenFix - pInfo->num_digits_fix;
        if( pInfo->exp_digits < 5 )
            pInfo->length_opt += 5 - pInfo->exp_digits;
        if( !pInfo->has_sign )
            pInfo->length_min += 1;
    else
        DBG_ASSERT( LenOut>=0 );
        *pszOut = 0;
        fb_hStrSetLength( dst, pszOut - dst->data );
    end if

    return TRUE
end function

FBCALL FBSTRING *fb_hStrFormat
	(
		double value,
        const char *mask,
        size_t mask_length
	)
{
    FBSTRING *dst = &__fb_ctx.null_desc;
    const char *pszIntlResult;
    char chDecimalPoint, chThousandsSep, chDateSep, chTimeSep;

    fb_ErrorSetNum( FB_RTERROR_OK );

    FB_LOCK();
    pszIntlResult = fb_IntlGet( eFIL_NumDecimalPoint, FALSE );
    chDecimalPoint = (( pszIntlResult==NULL ) ? '.' : *pszIntlResult );
    pszIntlResult = fb_IntlGet( eFIL_NumThousandsSeparator, FALSE );
    chThousandsSep = (( pszIntlResult==NULL ) ? ',' : *pszIntlResult );
    pszIntlResult = fb_IntlGet( eFIL_DateDivider, FALSE );
    chDateSep = (( pszIntlResult==NULL ) ? '/' : *pszIntlResult );
    pszIntlResult = fb_IntlGet( eFIL_TimeDivider, FALSE );
    chTimeSep = (( pszIntlResult==NULL ) ? ':' : *pszIntlResult );
    FB_UNLOCK();
    
    if( chDecimalPoint==0 )
        chDecimalPoint = '.';
    if( chThousandsSep==0 )
        chThousandsSep = ',';

    FB_STRLOCK();

    if( mask == NULL || mask_length==0 ) 
    {
        dst = fb_hBuildDouble( value, chDecimalPoint, 0 );
    } 
    else 
    {
        FormatMaskInfo info;

        /* Extract all information from the mask string */
        if( fb_hProcessMask( NULL,
                              mask, mask_length,
                              value, &info,
                              chThousandsSep, chDecimalPoint,
                              chDateSep, chTimeSep ) ) 
        {
            dst = fb_hStrAllocTemp_NoLock( NULL, info.length_min + info.length_opt );
            if( dst == NULL ) 
            {
                fb_ErrorSetNum( FB_RTERROR_OUTOFMEM );
                dst = &__fb_ctx.null_desc;
            }
		    else
            {
                /* Build the new string according to the mask */
                fb_hProcessMask( dst,
                                 mask, mask_length,
                                 value, &info,
                                 chThousandsSep, chDecimalPoint,
                                 chDateSep, chTimeSep );
            }
        }
    }

    FB_STRUNLOCK();

    return dst;
}

FBCALL FBSTRING *fb_StrFormat
	(
		double value,
		FBSTRING *mask
	)
{
    FBSTRING *dst;

    dst = fb_hStrFormat( value, mask->data, FB_STRSIZE(mask) );

	/* del if temp */
	fb_hStrDelTemp( mask );

    return dst;
}
