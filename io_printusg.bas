/' print using function '/

#include "fb.bi"
#include "crt/math.bi"

type FB_PRINTUSGCTX
	as long       chars
	as ubyte ptr  _ptr
	as FBSTRING   fmtstr
end type

#define BUFFERLEN 2048
#define MIN_EXPDIGS 3
#define MAX_EXPDIGS 5
#define MAX_DIGS (BUFFERLEN                                 _
                   - 2                 /' '%' char(s)   '/  _
                   - 1                 /' +/- sign      '/  _
                   - 1                 /' dollar sign   '/  _
                   - 1                 /' decimal point '/  _
                   - MAX_EXPDIGS       /' exp digits    '/  _
                   - (MIN_EXPDIGS - 1) /' stray carets  '/  _
                 )


#define CHAR_ZERO        asc("0")
#define CHAR_DOT         asc(".")
#define CHAR_COMMA       asc(",")
#define CHAR_TOOBIG      asc("%")
#define CHAR_PLUS        asc("+")
#define CHAR_MINUS       asc("-")
#define CHAR_STAR        asc("*")
#define CHAR_DOLLAR      asc("$")
#define CHAR_SPACE       asc(" ")
#define CHAR_WTF         asc("!")
#define CHAR_EXP_SINGLE  asc("E")
#if 0
#define CHAR_EXP_DOUBLE  asc("D")
#endif

#define SNG_AUTODIGS 7
#define DBL_AUTODIGS 15
#define DBL_MAXDIGS 16

#define CHARS_NAN   (asc("#") shl 24 or asc("N") shl 16 or asc("A") shl 8 or asc("N"))
#define CHARS_INF   (asc("#") shl 24 or asc("I") shl 16 or asc("N") shl 8 or asc("F"))
#define CHARS_IND   (asc("#") shl 24 or asc("I") shl 16 or asc("N") shl 8 or asc("D"))
#define CHARS_TRUNC (asc("$") shl 24 or asc("0") shl 16 or asc("0") shl 8 or asc("0")) /' QB glitch: truncation "rounds up" the text chars '/

#define CHARS_TRUE  (asc("t") shl 24 or asc("r") shl 16 or asc("u") shl 8 or asc("e"))
#define CHARS_FALSE ((cast(uint64_t, asc("f"))) shl 32 or asc("a") shl 24 or asc("l") shl 16 or asc("s") shl 8 or asc("e"))

#macro ADD_CHAR( c )              
	DBG_ASSERT( p >= @buffer(0) )
	if ( p >= @buffer(0) ) then
		*p = cast(ubyte, c)
		p -= 1
	elseif ( p = @buffer(0) ) then
		*p = CHAR_WTF
	end if
#endmacro


extern "C"

'' !!!TODO!!! see note in fb_thread.bi::_FB_TLSGETCTX(id)
'' #define fb_PRINTUSGCTX_Destructor NULL
 
sub fb_PRINTUSGCTX_Destructor( byval data_ as any ptr )
end sub

/'-------------------------------------------------------------'/
/' Checks for Infinity/NaN                                     *
 * (assumes IEEE-754 floating-point format)                    *
 * TODO: use a proper implementation: most/all platforms       *
 * have specific functions built-in for this                   '/

private function hDoubleToLongBits( d as double ) as longint
	union _dtoll
		as double d
		as ulongint ll
	end union
	dim as _dtoll dtoll
	dtoll.d = d
	return dtoll.ll
end function

private function hIsNeg( d as double ) as long
	return hDoubleToLongBits(d) < 0ll
end function

private function hIsZero(d as double) as long
	return (hDoubleToLongBits(d) and &h7fffffffffffffffll) = 0ll
end function

private function hIsFinite(d as double) as long
	return (hDoubleToLongBits(d) and &h7ff0000000000000ll) < &h7ff0000000000000ll
end function

private function hIsInf(d as double) as long
	return (hDoubleToLongBits(d) and &h7fffffffffffffffll) = &h7ff0000000000000ll
end function

private function hIsInd(d as double) as long
	return (hDoubleToLongBits(d) = cast(longint, &hfff8000000000000ll))
end function

private function hIsNan( d as double ) as long
	return not(hIsFinite(d) or hIsInf(d) or hIsInd(d))
end function



/'-------------------------------------------------------------'/

#define VAL_ISNEG 	&h1
#define VAL_ISINF 	&h2
#define VAL_ISIND 	&h4
#define VAL_ISNAN 	&h8

#define VAL_ISFLOAT &h10
#define VAL_ISSNG 	&h20

#define VAL_ISBOOL 	&h40


declare function fb_PrintUsingFmtStr( fnum as long ) as long

function fb_PrintUsingInit FBCALL ( fmtstr as FBSTRING ptr ) as long
    dim as FB_PRINTUSGCTX ptr ctx

    FB_LOCK()

    ctx = _FB_TLSGETCTX( PRINTUSG )

	fb_StrAssign( cast(any ptr, @ctx->fmtstr), -1, fmtstr, -1, 0 )
	ctx->_ptr = ctx->fmtstr.data
	ctx->chars = FB_STRSIZE( @ctx->fmtstr )

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_PrintUsingEnd FBCALL ( fnum as long ) as long
	dim as FB_PRINTUSGCTX ptr ctx

	fb_PrintUsingFmtStr( fnum )

	FB_LOCK()

	ctx = _FB_TLSGETCTX( PRINTUSG )

	fb_StrDelete( @ctx->fmtstr )
	ctx->_ptr = 0
	ctx->chars = 0

	FB_UNLOCK()

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

private function hPow10_ULL( n as long ) as ulongint

	DBG_ASSERT( n >= 0 and n <= 19 )

	dim as ulongint ret = 1, a = 10
	while( n > 0 )
		if ( n and 1 ) then ret *= a
		a *= a
		n shr= 1
	wend

	return ret
end function

private function hLog10_ULL( a as ulongint ) as long
	dim as long ret = 0
	dim as long a32
	dim as ulongint a64

	a64 = a
	while( a64 >= cast(long, 1.E+8) )
		a64 /= cast(long, 1.E+8)
		ret += 8
	wend
	a32 = a64
	if( a32 >= cast(long, 1.E+4) ) then ret += 4 else a32 *= cast(long, 1.E+4)
	if( a32 >= cast(long, 1.E+6) ) then ret += 2 else a32 *= cast(long, 1.E+2)
	if( a32 >= cast(long, 1.E+7) ) then ret += 1

	if ( a = 0 ) then
		DBG_ASSERT( ret = 0 )
	else
		DBG_ASSERT( hPow10_ULL( ret ) <= a and hPow10_ULL( ret ) > a / 10 )
	end if

	return ret
end function

private function hNumDigits( a as ulongint ) as long
	 return hLog10_ULL( a ) + 1
end function

private function hDivPow10_ULL( a as ulongint, n as long ) as ulongint
	dim as ulongint b, ret

	DBG_ASSERT( n >= 0 )

	if ( n > 19 ) then return 0

	b = hPow10_ULL( n )
	ret = a / b

	if( (a mod b) >= (b + 1) / 2 ) then
		ret += 1 /' round up '/
	end if

	return ret
end function

private function fb_PrintUsingFmtStr( fnum as long ) as long
	dim as FB_PRINTUSGCTX ptr ctx
	dim as ubyte buffer(0 to BUFFERLEN)
	dim as long c, nc, nnc, _len, doexit

	ctx = _FB_TLSGETCTX( PRINTUSG )

	_len = 0
	if ( ctx->_ptr = NULL ) then
		ctx->chars = 0
	end if

	while( (ctx->chars > 0) and (_len < BUFFERLEN) )
		c = *ctx->_ptr
		nc = iif( ctx->chars > 1, ctx->_ptr[1], -1 )
		nnc = iif( ctx->chars > 2, ctx->_ptr[2], -1 )

		doexit = FALSE
		select case( c )
			case asc("*"):
				/' "**..." number format (includes "**$...") '/
				if ( nc = asc("*") ) then
					doexit = TRUE
				end if

			case asc("$"):
				/' "$$..." number format '/
				if ( nc = asc("$") ) then
					doexit = TRUE
				end if
				
			case asc("+"):
				/' "+#...", "+$$...", "+**...", "+.#..." '/
				if ( (nc = asc("#")) or _
					((nc = asc("$")) and (nnc = asc("$"))) or _
					((nc = asc("*")) and (nnc = asc("*"))) or _
					((nc = asc(".")) and (nnc = asc("#"))) ) then

					doexit = TRUE
				end if
			case asc("!"), asc("\"), asc("&"), asc("#"):
				/' "!", "\ ... \", "&" string formats, "#..." number format '/
				doexit = TRUE

			case asc("."):
				/' ".#[...]" number format '/
				if ( nc = asc("#") ) then
					doexit = TRUE
				end if

			case asc("_"):
				/' escape next char if there is one, otherwise just print '_' '/
				if ( ctx->chars > 1 ) then
					c = nc
					ctx->_ptr += 1
					ctx->chars -= 1
				end if
		end select

		if( doexit = TRUE ) then
			exit while
		end if
		
		_len += 1
		buffer(_len) = cast(ubyte, c)

		ctx->_ptr += 1
		ctx->chars -= 1
	wend

	/' flush '/
	if ( _len > 0 ) then
		buffer(_len) = 0
		fb_PrintFixString( fnum, @buffer(0), 0 )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_PrintUsingStr FBCALL ( fnum as long, s as FBSTRING ptr, mask as long ) as long
	dim as FB_PRINTUSGCTX ptr ctx
	dim as ubyte buffer(0 to BUFFERLEN)
	dim as long c, nc, strchars, doexit, i

	ctx = _FB_TLSGETCTX( PRINTUSG )

    /' restart if needed '/
	if ( ctx->chars = 0 ) then
		ctx->_ptr = ctx->fmtstr.data
		ctx->chars = FB_STRSIZE( @ctx->fmtstr )
	end if

	/' any text first '/
	fb_PrintUsingFmtStr( fnum )

	strchars = -1

	if ( ctx->_ptr = NULL ) then
		ctx->chars = 0
	end if

	while( ctx->chars > 0 )
		c = *ctx->_ptr
        nc = iif( ctx->chars > 1, ctx->_ptr[1], -1 )

		doexit = TRUE
		select case ( c )
			case asc("!"):
				if ( FB_STRSIZE( s ) >= 1 ) then
					buffer(0) = s->data[0]
				else
					buffer(0) = asc(" ")
				end if

				buffer(1) = 0
				fb_PrintFixString( fnum, @buffer(0), 0 )

				ctx->_ptr += 1
				ctx->chars -= 1

			case asc("&"):
				fb_PrintFixString( fnum, s->data, 0 )

				ctx->_ptr += 1
				ctx->chars -= 1

			case asc("\"):
				if ( (strchars <> -1) or (nc = asc(" ")) or (nc = asc("\")) ) then
					if ( strchars > 0 ) then
						strchars += 1

						if ( FB_STRSIZE( s ) < strchars ) then
							fb_PrintFixString( fnum, s->data, 0 )

							strchars -= FB_STRSIZE( s )
							for i = 0 to strchars - 1
								buffer(i) = asc(" ")
							next
							buffer(i) = 0
						else
							memcpy( @buffer(0), s->data, strchars )
							buffer(strchars) = 0
						end if

						/' replace null-terminators by spaces '/
						for i = 0 to strchars - 1
							if ( buffer(i) = 0 ) then
								buffer(i) = asc(" ")
							end if
						next

						fb_PrintFixString( fnum, @buffer(0), 0 )

						ctx->_ptr += 1
						ctx->chars -= 1
					else
						strchars = 1
						doexit = FALSE
					end if
				end if

			case asc(" "):
				if ( strchars > -1 ) then
					strchars += 1
					doexit = FALSE
				end if
		end select

		if ( doexit = TRUE ) then
			exit while
		end if

		ctx->_ptr += 1
		ctx->chars -= 1
	wend

	/' any text '/
	fb_PrintUsingFmtStr( fnum )

	/''/
	if ( mask and FB_PRINT_ISLAST ) then
		if ( mask and FB_PRINT_NEWLINE ) then
			fb_PrintVoid( fnum, FB_PRINT_NEWLINE )
		end if

		fb_StrDelete( @ctx->fmtstr )
	end if

	/' del if temp '/
	fb_hStrDelTemp( s )

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

function fb_PrintUsingWstr FBCALL ( fnum as long, s as FB_WCHAR ptr, mask as long ) as long
	dim as FB_PRINTUSGCTX ptr ctx
	dim as FB_WCHAR buffer(0 to BUFFERLEN)
	dim as long c, nc, strchars, doexit, i, length

	ctx = _FB_TLSGETCTX( PRINTUSG )

	/' restart if needed '/
	if ( ctx->chars = 0 ) then
		ctx->_ptr = ctx->fmtstr.data
		ctx->chars = FB_STRSIZE( @ctx->fmtstr )
	end if

	/' any text first '/
	fb_PrintUsingFmtStr( fnum )

	strchars = -1
	length = fb_wstr_Len( s )

	if ( ctx->_ptr = NULL ) then
		ctx->chars = 0
	end if

	while( ctx->chars > 0 )
		c = *ctx->_ptr
		nc = iif(ctx->chars > 1, ctx->_ptr[1], -1)
		doexit = TRUE
		select case ( c )
			case asc("!"):
				if ( length >= 1 ) then
					buffer(0) = s[0]
				else
					buffer(0) = asc(" ")
				end if

				buffer(1) = 0
				fb_PrintWstr( fnum, @buffer(0), 0 )

				ctx->_ptr += 1
				ctx->chars -= 1

			case asc("&"):
				fb_PrintWstr( fnum, s, 0 )

				ctx->_ptr += 1
				ctx->chars -= 1

			case asc("\"):
				if ( (strchars <> -1) or (nc = asc(" ")) or (nc = asc(!"\\")) ) then
					if ( strchars > 0 ) then
						strchars += 1

						if ( length < strchars ) then
							fb_PrintWstr( fnum, s, 0 )

							strchars -= length
							for i = 0 to strchars - 1
								buffer(i) = asc(" ")
							next
							buffer(i) = 0
						else
							fb_wstr_Copy( @buffer(0), s, strchars )
						end if

						/' replace null-terminators by spaces '/
						for i = 0 to strchars - 1
							if ( buffer(i) = 0 ) then
								buffer(i) = asc(" ")
							end if
						next

						fb_PrintWstr( fnum, @buffer(0), 0 )

						ctx->_ptr += 1
						ctx->chars -= 1
					else
						strchars = 1
						doexit = FALSE
					end if
				end if

			case asc(" "):
				if ( strchars > -1 ) then
					strchars += 1
					doexit = FALSE
				end if
		end select

		if ( doexit = TRUE ) then
			exit while
		end if

		ctx->_ptr += 1
		ctx->chars -= 1
	wend

	/' any text '/
	fb_PrintUsingFmtStr( fnum )

	/''/
	if ( mask and FB_PRINT_ISLAST ) then
		if ( mask and FB_PRINT_NEWLINE ) then
			fb_PrintVoid( fnum, FB_PRINT_NEWLINE )
		end if
		fb_StrDelete( @ctx->fmtstr )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

private function hPrintNumber( fnum as long, _val as ulongint, val_exp as long, flags as long, mask as long ) as long
	dim as FB_PRINTUSGCTX ptr ctx
	dim as ubyte buffer(0 to BUFFERLEN) 
	dim as ubyte ptr p
	dim as long val_digs, val_zdigs
	dim as ulongint val0
	dim as long val_digs0, val_exp0
	dim as long valIsneg, valIsfloat, valIssng
	dim as long c, lc
#ifdef __FB_DEBUG__
	dim as long nc /' used for sanity checks '/
#endif
	dim as long doexit, padchar, intdigs, decdigs, expdigs
	dim as long adddollar, addcommas, signatend, signatstart, plussign, toobig
	dim as long intdigs2, expsignchar, totdigs, decpoint
	dim as long isamp
	dim as long i
	dim as uint64_t chars = 0

	ctx = _FB_TLSGETCTX( PRINTUSG )

	/' restart if needed '/
	if ( ctx->chars = 0 ) then
		ctx->_ptr = ctx->fmtstr.data
		ctx->chars = FB_STRSIZE( @ctx->fmtstr )
	end if

	/' any text first '/
	fb_PrintUsingFmtStr( fnum )

	/''/
	padchar     = CHAR_SPACE
	intdigs     = 0
	decdigs     = -1
	expdigs     = 0
	adddollar   = FALSE
	addcommas   = FALSE
	signatend   = FALSE
	signatstart = FALSE
	plussign    = FALSE
	toobig      = 0
	isamp       = FALSE

	lc = -1

	if ( ctx->_ptr = NULL ) then
		ctx->chars = 0
	end if

	while( ctx->chars > 0 )
		/' exit if just parsed end '+'/'-' sign, or '&' sign '/
		if ( signatend <> NULL or isamp <> NULL ) then
			exit while
		end if

		c = *ctx->_ptr
#ifdef __FB_DEBUG__
		nc = iif( ctx->chars > 1, *(ctx->_ptr+1), -1 )
#endif
		doexit = FALSE
		select case( c )
			case asc("#"):
				/' increment intdigs or decdigs if in int/dec part, else exit '/
				if ( expdigs <> 0 ) then
					doexit = TRUE
				elseif ( decdigs <> -1 ) then
					decdigs += 1
				else
					intdigs += 1
				end if

			case asc("."):
				/' add decimal point if still in integer part, else exit '/
				if ( decdigs <> -1 or expdigs <> 0 ) then
					doexit = TRUE
				else
					decdigs = 0
				end if

			case asc("*"):
				/' if first two characters, change padding to asterisks, else exit '/
				if ( (intdigs = 0 and decdigs = -1) ) then
					/' first asterisk '/
					DBG_ASSERT( nc = asc("*") ) /' must be two at start, otherwise we're not parsing a format string and shouldn't have been brought here! '/
					padchar = CHAR_STAR
					intdigs += 1
				elseif ( intdigs = 1 and lc = asc("*") ) then
					/' second asterisk '/
					intdigs += 1
				else
					doexit = TRUE
				end if

			case asc("$"):
				/' at beginning ("$..."), or after two '*'s ("**$..."): prepend a dollar sign to number '/

				/' did it follow a '*'? (Will have been the two at the start, else would have exited by now '/
				if ( lc = asc("*") ) then
					adddollar = TRUE
				/' two at start of number, before integer part? '/
				elseif ( intdigs = 0 and decdigs = -1 ) then
					if ( adddollar = FALSE ) then
						/' first dollar '/
						DBG_ASSERT( nc = asc("$") ) /' otherwise we're not parsing a format string and shouldn't have been brought here! '/
						adddollar = TRUE
					else
						/' second dollar '/
						DBG_ASSERT( lc = asc("$") )
						intdigs += 1
					end if
				else
					doexit = TRUE
				end if

			case asc(","):
				/' if parsing integer part, enable commas and increment intdigs '/
				if ( decdigs <> -1 or expdigs <> 0 ) then
					doexit = TRUE
				else
					addcommas = TRUE
					intdigs += 1
				end if

			case asc("+"), asc("-"):
				/' '+' at start/end:  explicit '+'/'-' sign
				   '-' at end:  explicit '-' sign, if negative '/

				/' one already at start? '/
				if ( signatstart = TRUE ) then
					doexit = TRUE
				/' found one before integer part? '/
				elseif ( intdigs = 0 and decdigs = -1 ) then
					DBG_ASSERT( c <> asc("-") ) /' explicit '-' sign isn't checked for at start '/
					if ( c = asc("+") ) then
						plussign = TRUE
					end if
					signatstart = TRUE
				/' otherwise it's at the end, as long as there are enough expdigs for an
				   exponent (or none at all), otherwise they are all normal printable characters '/
				elseif ( expdigs = 0 or expdigs >= MIN_EXPDIGS ) then
					if ( c = asc("+") ) then
						plussign = TRUE
					end if
					signatend = TRUE
				else
					doexit = TRUE
				end if

			case asc("^"):
				/' exponent digits (there must be at least MIN_EXPDIGS of them,
				   otherwise they will just be appended as printable chars      '/

				/' Too many? Leave the rest as printable chars '/
				if ( expdigs < MAX_EXPDIGS ) then
					expdigs += 1
				else
					doexit = TRUE
				end if

			case asc("&"):
				/' string format '&'
				   print number in most natural form - similar to STR '/
				if ( intdigs = 0 and decdigs = -1 and signatstart = FALSE ) then
					DBG_ASSERT( expdigs = 0 )
					isamp = TRUE
				else
					doexit = TRUE
				end if

			case else:
				doexit = TRUE
		end select

		if ( doexit = TRUE ) then
			exit while
		end if

		ctx->_ptr += 1
		ctx->chars -= 1

		lc = c
	wend

	/' ------------------------------------------------------ '/

	/' check flags '/
	valIsneg = ( (flags and VAL_ISNEG) <> 0 )
	valIsfloat = ( (flags and VAL_ISFLOAT) <> 0 )
	valIssng = ( (flags and VAL_ISSNG) <> 0 )

	if ( (flags and (VAL_ISINF or VAL_ISIND or VAL_ISNAN)) <> 0) then
		if ( (flags and VAL_ISINF) <> 0 ) then
			chars = CHARS_INF
		elseif ( (flags and VAL_ISIND) <> 0 ) then
			chars = CHARS_IND
		elseif ( (flags and VAL_ISNAN) <> 0 ) then
			chars = CHARS_NAN
		else
			DBG_ASSERT( 0 )
		end if

		/' Set value to 1.1234 (placeholder for "1.#XYZ") '/
		_val = 11234
		val_exp = -4
	end if

	if ( isamp and (flags and VAL_ISBOOL) <> 0 ) then
		/' String value for "&": return "true"/"false"
		   (use val to placehold digits) '/
		if ( _val <> 0 ) then
			chars = CHARS_TRUE
			_val = 1234
			valIsneg = FALSE
		else
			chars = CHARS_FALSE
			_val = 12345
		end if
		val_exp = 0
	end if

	if ( _val <> 0 ) then
		val_digs = hNumDigits( _val )
	else
		val_digs = 0
	end if
	val_zdigs = 0

	/' Special '&' format? '/
	if ( isamp = TRUE ) then
		if ( val_issng = TRUE ) then
			/' crop to 7-digit precision '/
			if ( val_digs > SNG_AUTODIGS ) then
				_val = hDivPow10_ULL( _val, val_digs - SNG_AUTODIGS )
				val_exp += val_digs - SNG_AUTODIGS
				val_digs = SNG_AUTODIGS
			end if

			if ( _val = 0 ) then
				/' val has been scaled down to zero '/
				val_digs = 0
				val_exp = -decdigs
			elseif ( _val = hPow10_ULL( val_digs ) ) then
				/' rounding up took val to next power of 10:
				   set value to 1, put val_digs zeroes onto val_exp '/
				_val = 1
				val_exp += val_digs
				val_digs = 1
			end if
		end if

		if ( val_isfloat = TRUE ) then
			/' remove trailing zeroes in float digits '/
			while( val_digs > 1 and (_val mod 10) = 0 )
				_val /= 10
				val_digs -= 1
				val_exp += 1
			wend
		end if

		/' set digits for fixed-point '/
		if ( val_digs + val_exp > 0 ) then
			intdigs = val_digs + val_exp
		else
			intdigs = 1
		end if

		if ( val_exp < 0 ) then
			decdigs = -val_exp
		end if

		if ( val_isfloat = TRUE ) then
			/' scientific notation? e.g. 3.1E+42 '/
			if ( intdigs > 16 or (val_issng and intdigs > 7) or _
			    val_digs + val_exp - 1 < -MIN_EXPDIGS ) then
				intdigs = 1
				decdigs = val_digs - 1

				expdigs = 2 + hNumDigits( abs(val_digs + val_exp - 1) )
				if ( expdigs < MIN_EXPDIGS + 1 ) then
					expdigs = MIN_EXPDIGS
				end if
			end if
		end if

		if ( val_isneg = TRUE ) then
			signatstart = TRUE
		end if
	end if

	/' crop number of digits '/
	if ( intdigs + 1 + decdigs > MAX_DIGS ) then
		decdigs -= ((intdigs + 1 + decdigs) - MAX_DIGS)
		if ( decdigs < -1 ) then
			intdigs -= (-1 - decdigs)
			decdigs = -1
		end if
	end if

	/' decimal point if decdigs >= 0 '/
	if ( decdigs <= -1 ) then
		decpoint = FALSE
		decdigs = 0
	else
		decpoint = TRUE
	end if

	/' ------------------------------------------------------ '/

	p = @buffer(BUFFERLEN)
	ADD_CHAR( 0 )

	if ( signatend = TRUE ) then
		/' put sign at end '/
		if ( val_isneg = TRUE ) then
			ADD_CHAR( CHAR_MINUS )
		else
			ADD_CHAR( iif(plussign = TRUE, CHAR_PLUS, CHAR_SPACE) )
		end if
	elseif ( val_isneg = TRUE and signatstart = FALSE ) then
		/' implicit negative sign at start '/
		signatstart = TRUE
		intdigs -= 1
	end if

	/' fixed-point format? '/
	if ( expdigs < MIN_EXPDIGS ) then
		/' append any trailing carets '/
		for j as long = expdigs to 1 step -1
			ADD_CHAR( asc("^") )
		next

		/' backup unscaled value '/
		val0 = _val
		val_digs0 = val_digs
		val_exp0 = val_exp

		/' check range '/
		if ( val_exp < -decdigs ) then
			/' scale and round integer value to get val_exp equal to -decdigs '/
			val_exp += (-decdigs - val_exp0)
			val_digs -= (-decdigs - val_exp0)
			_val = hDivPow10_ULL( _val, -decdigs - val_exp0 )

			if ( _val = 0 ) then
				/' val is/has been scaled down to zero '/
				val_digs = 0
				val_exp = -decdigs
			elseif ( _val = hPow10_ULL( val_digs ) ) then
				/' rounding up took val to next power of 10:
				   set value to 1, put val_digs zeroes onto val_exp '/
				_val = 1
				val_exp += val_digs
				val_digs = 1
			end if
		end if

		intdigs2 = val_digs + val_exp
		if ( intdigs2 < 0 ) then intdigs2 = 0
		if( addcommas = TRUE ) then
			intdigs2 += (intdigs2 - 1) / 3
		end if

		/' compare fixed/floating point representations,
		   and use the one that needs fewest digits '/
		if ( intdigs2 > intdigs + MIN_EXPDIGS ) then
			/' too many digits in number for fixed point:
			   switch to floating-point '/

			expdigs = MIN_EXPDIGS /' add three digits for exp notation (was four in QB) '/
			toobig = 1  /' add '%' sign '/

			/' restore unscaled value '/
			_val = val0
			val_digs = val_digs0
			val_exp = val_exp0

			val_zdigs = 0
		else
			/' keep fixed point '/

			if ( intdigs2 > intdigs ) then
				/' slightly too many digits in number '/
				intdigs = intdigs2  /' extend intdigs '/
				toobig = 1          /' add '%' sign '/
			end if

			if ( val_exp > -decdigs) then
				/' put excess trailing zeroes from val_exp into val_zdigs '/
				val_zdigs = val_exp - -decdigs
				val_exp = -decdigs
			end if
		end if
	end if


	/' floating-point format '/
	if ( expdigs > 0 ) then
		addcommas = FALSE /' commas unused in f-p format '/

		if ( intdigs = -1 or (intdigs = 0 and decdigs = 0) ) then
			/' add [another] '%' sign '/
			intdigs += 1
#if 0
			toobig += 1   /' QB could prepend two independent '%'s '/
#else
			toobig = 1 /' We'll just stick with one '/
#endif
		end if

		totdigs = intdigs + decdigs /' treat intdigs and decdigs the same '/
		val_exp += decdigs /' move decimal position to end '/

		/' blank first digit if positive and no explicit sign
		   (pos/neg numbers should be formatted the same where
		   possible, as in QB) '/
		if ( isamp = FALSE and val_isneg = FALSE and (signatstart or signatend) = FALSE ) then
			if ( intdigs >= 1 and totdigs > 1 ) then
				totdigs -= 1
			end if
		end if

		if ( _val = 0 ) then
			val_exp = 0         /' ensure exponent is printed as 0 '/
			val_zdigs = decdigs /' enough trailing zeroes to fill dec part '/
		elseif ( val_digs < totdigs ) then
			/' add "zeroes" to the end of val:
			   subtract from val_exp and put into val_zdigs '/
			val_zdigs = totdigs - val_digs 
			val_exp -= val_zdigs
		elseif ( val_digs > totdigs ) then
			/' scale down value '/
			_val = hDivPow10_ULL( _val, val_digs - totdigs )
			val_exp += (val_digs - totdigs)
			val_digs = totdigs
			val_zdigs = 0

			if ( _val >= hPow10_ULL( val_digs ) ) then
				/' rounding up brought val to the next power of 10:
				   add the extra digit onto val_exp '/
				_val /= 10
				val_exp += 1
			end if
		else
			val_zdigs = 0
		end if


		/' output exp part '/

		if ( val_exp < 0 ) then
			expsignchar = CHAR_MINUS
			val_exp = -val_exp
		else
			expsignchar = CHAR_PLUS
		end if

		/' expdigs > 3 '/
		for j as long = expdigs to 4 step -1
			ADD_CHAR( CHAR_ZERO + (val_exp mod 10) )
			val_exp /= 10
		next

		/' expdigs == 3 '/
		if ( val_exp > 9 ) then /' too many exp digits? '/
#if 1		/' Add remaining digits (QB would just crop these) '/
			do
				ADD_CHAR( CHAR_ZERO + (val_exp mod 10) )
				val_exp /= 10
			loop while( val_exp > 9 )
			ADD_CHAR( CHAR_ZERO + val_exp )
#endif
			ADD_CHAR( CHAR_TOOBIG ) /' add a '%' sign '/
		else
			ADD_CHAR( CHAR_ZERO + val_exp )
		end if

		expdigs -= 1

		/' expdigs = 2 '/
		ADD_CHAR( expsignchar )
		ADD_CHAR( CHAR_EXP_SINGLE ) /' QB would use 'D' for doubles '/

		expdigs -= 2
	end if


	/' INF/IND/NAN: characters truncated? '/
	if ( chars <> 0 and val_digs < 5 and (flags and VAL_ISBOOL) = 0) then
		/' QB wouldn't add the '%'.  But otherwise "#" will result in
		   an innocent-looking "1".  Also, QB corrupts the string data
		   when truncated, so some deviation is desirable anyway) '/
		toobig = 1

		if ( val_digs > 1 ) then
			chars = CHARS_TRUNC shr (8 * (5 - val_digs))
		else
			chars = 0
		end if
	end if


	/' output dec part '/
	if ( decpoint = TRUE ) then
		for j as long = decdigs to 1 step -1
			if ( val_zdigs > 0 ) then
				ADD_CHAR( CHAR_ZERO )
				val_zdigs -= 1
			elseif ( val_digs > 0 ) then
				DBG_ASSERT( _val > 0 )
				if ( chars <> 0 ) then
					ADD_CHAR( chars and &hff )
					chars shr= 8
				else
					ADD_CHAR( CHAR_ZERO + (_val mod 10) )
				end if
				_val /= 10
				val_digs -= 1
			else
				ADD_CHAR( CHAR_ZERO )
			end if
		next
		ADD_CHAR( CHAR_DOT )
	end if


	/' output int part '/
	i = 0
	'for( ;; )
	'{
	do
		if ( addcommas = TRUE and (i and 3) = 3 and val_digs > 0 ) then
			/' insert comma '/
			ADD_CHAR( CHAR_COMMA )
		elseif ( val_zdigs > 0 ) then
			ADD_CHAR( CHAR_ZERO )
			val_zdigs -= 1
		elseif ( val_digs > 0 ) then
			DBG_ASSERT( _val > 0 )
			if ( chars <> 0 ) then
				ADD_CHAR( chars and &hff )
				chars shr= 8
			else
				ADD_CHAR( CHAR_ZERO + (_val mod 10) )
			end if
			_val /= 10
			val_digs -= 1
		else
			if ( i = 0 and intdigs > 0 ) then
				ADD_CHAR( CHAR_ZERO )
			else
				exit do
				'exit for
			end if
		end if
		DBG_ASSERT( intdigs > 0 )
		i += 1
		intdigs -= 1
	loop
	'}

	DBG_ASSERT( _val = 0 )
	DBG_ASSERT( val_digs = 0 )
	DBG_ASSERT( val_zdigs = 0 )

	DBG_ASSERT( decdigs = 0 )
	DBG_ASSERT( expdigs = 0 )
	DBG_ASSERT( intdigs >= 0 )

	/' output dollar sign? '/
	if ( adddollar = TRUE ) then
		ADD_CHAR( CHAR_DOLLAR )
	end if

	/' output sign? '/
	if ( signatstart = TRUE ) then
		if ( val_isneg = TRUE ) then
			ADD_CHAR( CHAR_MINUS )
		else
			ADD_CHAR( iif(plussign = TRUE, CHAR_PLUS, padchar) )
		end if
	end if

	/' output padding for any remaining intdigs '/
	for j as long = intdigs to 1 step -1
		ADD_CHAR( padchar )
	next

	/' output '%' sign(s)? '/
	for j as long = toobig to 1 step -1
		ADD_CHAR( CHAR_TOOBIG )
	next


	/''/
	p += 1
	fb_PrintFixString( fnum, p, 0 )

	/' ------------------------------------------------------ '/

	/' any text '/
	fb_PrintUsingFmtStr( fnum )

	/''/
	if ( mask and (FB_PRINT_NEWLINE or FB_PRINT_PAD) ) then
		fb_PrintVoid( fnum, mask and (FB_PRINT_NEWLINE or FB_PRINT_PAD) )
	end if

	if ( mask and FB_PRINT_ISLAST ) then
		fb_StrDelete( @ctx->fmtstr )
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function

private function hScaleDoubleToULL( value as double, pval_exp as long ptr ) as ulongint
	DBG_ASSERT( value >= 0.0 )

#if 0
	/* scale down to a 16-digit number, plus base-10 exponent */

	if( value == 0.0 )
	{
		*pval_exp = 0;
		return 0;
	}
	long double val_ld = value;
	unsigned long long val_ull;
	int val_exp;

	/* find number of digits in double (approximation, may be 1 lower) */

	val_exp = 1 + (int)floor( log10( val_ld ) - 0.5 );

	/* scale down to 16..17 digits (use long doubles to prevent inaccuracy/overflow in pow) */
	val_exp -= 16;
	val_ld /= pow( (long double)10.0, val_exp );
	if( val_ld >= (long double)1.E+16 )
	{
		val_ld /= (long double)10.0;
		++val_exp;
	}

	/* convert to ULL */
	val_ull = (unsigned long long)(val_ld + 0.5);
	DBG_ASSERT( val_ull >= (unsigned long long)1.E+15 || val_ull == 0 );
	DBG_ASSERT( val_ull <= (unsigned long long)1.E+16 );

	*pval_exp = val_exp;
	return val_ull;
#else

	/'(assumes x86 endian, IEEE-754 floating-point format) '/

	dim as ulongint val_ull
	dim as long digs
	dim as long pow2, pow10

	val_ull = hDoubleToLongBits( value )
	pow2 = (val_ull shr 52) - 1023
	val_ull and= (1ull shl 52)-1

	if ( pow2 > -1023 ) then
		/' normalized '/
		val_ull or= (1ull shl 52)
	else
		/' denormed '/
		pow2 += 1
	end if
	pow2 -= 52 /' 52 (+1?) integer bits in val_ull '/

	pow10 = 0

	while( pow2 > 0 )
		/' essentially, val_ull*=2, --pow2,
		 * dividing by 5 when necessary to keep within 64 bits) '/
		if ( val_ull < (1ull shl 63) ) then
			val_ull *= 2
			pow2 -= 1
		else
			/' divide by 5, rounding to nearest
			 * (val_ull will be much bigger than 3 so no underflow) '/
			val_ull = (val_ull - 3) / 5 + 1
			pow10 += 1
			pow2 -= 1
		end if
	wend

	while( pow2 < 0 )
		/' essentially, val_ull/=2, ++pow2,
		 * multiplying by 5 when possible to keep precision high '/
		if ( val_ull <= &h3333333333333333ull ) then
			/' multiply by 5 (max 0xffffffffffffffff) '/
			val_ull *= 5
			pow10 -= 1
			pow2 += 1
		else
			/' divide by 2, rounding to even '/
			val_ull = val_ull / 2 + (val_ull and (val_ull / 2) and 1)
			pow2 += 1
		end if
	wend

	digs = hNumDigits( val_ull )
	if ( digs > DBL_MAXDIGS ) then
		/' scale to 16 digits '/

		dim as long scale = digs - DBL_MAXDIGS
		val_ull = hDivPow10_ULL( val_ull, scale )
		pow10 += scale

		DBG_ASSERT( val_ull <= hPow10_ULL( DBL_MAXDIGS ) )
	end if

	*pval_exp = pow10
	return val_ull

#endif
end function

function fb_PrintUsingDouble FBCALL ( fnum as long, value as double, mask as long ) as long
	dim as long val_exp = 0
	dim as long flags
	dim as ulongint val_ull = 1

	flags = VAL_ISFLOAT

	if ( hIsNeg( value ) = TRUE ) then
		flags or= VAL_ISNEG
	end if

	if ( hIsZero( value ) = TRUE ) then
		val_ull = 0
		val_exp = 0
	elseif ( hIsFinite( value ) = TRUE ) then
		value = fabs( value )
		val_ull = hScaleDoubleToULL( value, @val_exp )
	else
		if ( hIsInf( value ) = TRUE ) then
			flags or= VAL_ISINF
		elseif ( hIsInd( value ) = TRUE ) then
			flags or= VAL_ISIND
		elseif ( hIsNan( value ) = TRUE ) then
			flags or= VAL_ISNAN
		else
			DBG_ASSERT( 0 )
		end if
	end if

	return hPrintNumber( fnum, val_ull, val_exp, flags, mask )
end function

function fb_PrintUsingSingle FBCALL ( fnum as long, value_f as single, mask as long ) as long
	dim as long val_exp = 0
	dim as long flags
	dim as ulongint val_ull = 1

	flags = VAL_ISFLOAT or VAL_ISSNG

	if ( hIsNeg( value_f ) = TRUE ) then
		flags or= VAL_ISNEG
	end if

	if ( hIsZero( value_f ) = TRUE ) then
		val_ull = 0
		val_exp = 0
	elseif ( hIsFinite( value_f ) = TRUE ) then
		value_f = fabs( value_f )
		val_ull = hScaleDoubleToULL( value_f, @val_exp )
	else
		if ( hIsInf( value_f ) = TRUE ) then
			flags or= VAL_ISINF
		elseif ( hIsInd( value_f ) = TRUE ) then
			flags or= VAL_ISIND
		elseif ( hIsNan( value_f ) = TRUE ) then
			flags or= VAL_ISNAN
		else
			DBG_ASSERT( 0 )
		end if
	end if

	return hPrintNumber( fnum, val_ull, val_exp, flags, mask )
end function

function fb_PrintUsingULongint FBCALL ( fnum as long, value_ull as ulongint, mask as long ) as long
	return hPrintNumber( fnum, value_ull, 0, 0, mask )
end function

function fb_PrintUsingLongint FBCALL( fnum as long, val_ll as longint, mask as long ) as long
	dim as long flags
	dim as ulongint val_ull

	if ( val_ll < 0 ) then
		flags = VAL_ISNEG
		val_ull = -val_ll
	else
		flags = 0
		val_ull = val_ll
	end if

	return hPrintNumber( fnum, val_ull, 0, flags, mask )
end function

function fb_PrintUsingBoolean FBCALL ( fnum as long, _val as ubyte, mask as long ) as long
	dim as long flags = VAL_ISBOOL
	dim as ulongint val_ull

	if ( _val <> 0 ) then
		flags or= VAL_ISNEG
		val_ull = 1ull
	else
		val_ull = 0ull
	end if

	return hPrintNumber( fnum, val_ull, 0, flags, mask )
end function
end extern