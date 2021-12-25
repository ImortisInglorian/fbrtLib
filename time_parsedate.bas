/' parse a string date '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
/':::::'/
private function fb_hIsMonth( text as const ubyte ptr, text_len as size_t, end_text as const ubyte ptr ptr, short_name as long, localized as long ) as long
    dim as const ubyte ptr txt_end = text
    dim as long _month
    for _month = 1 to 12
        dim as FBSTRING ptr sMonthName = fb_IntlGetMonthName( _month, short_name, not(localized) )
        DBG_ASSERT( sMonthName <> NULL )
        scope
            dim as size_t month_len = FB_STRSIZE( sMonthName )
            dim as size_t _len = iif((text_len < month_len), text_len, month_len )
            dim as long is_same = (FB_MEMCMP( text, sMonthName->data, _len ) = 0)

            if ( is_same <> 0 ) then
                if ( text_len > _len ) then
                    if ( isalpha( FB_CHAR_TO_INT(text[_len]) ) = 0 ) then
                        txt_end = text + _len
                        exit for
                    end if
                else
                    txt_end = text + _len
                    exit for
                end if
            end if
        end scope
    next
    if ( _month <> 13 ) then
        if ( short_name <> 0 ) then
            /' There might follow a dot directly after the
             * abbreviated month name '/
            if ( *txt_end = asc(".") ) then
                txt_end += 1
			end if
        end if
    else
        _month = 0
    end if
    if ( end_text <> NULL ) then
        *end_text = txt_end
	end if
    return _month
end function

/':::::'/
private function fb_hFindMonth( text as const ubyte ptr, text_len as size_t, end_text as ubyte ptr ptr ) as long
    dim as long short_name = 0
    while( short_name <> 2 )
        dim as long localized = 2
        while( localized )
            localized -= 1
            dim as long _month = fb_hIsMonth( text, text_len, end_text, short_name, localized )
            if ( _month <> 0 ) then
                return _month
            end if
        wend
        short_name += 1
    wend
    return 0
end function

/':::::'/
private function fb_hDateOrder( pOrderDay as long ptr, pOrderMonth as long ptr, pOrderYear as long ptr ) as long
    dim as long order_month = 0, order_day = 1, order_year = 2, order_index = 0
    dim as long tmp = any, got_sep
    dim as ubyte short_format(0 to 89) = any

    tmp = fb_IntlGetDateFormat( @short_format(0), ARRAY_SIZEOF(short_format), FALSE )
    if ( tmp = 0 ) then
        return FALSE
    end if

    got_sep = TRUE
    tmp = 0
    while( short_format(tmp) <> 0 )
        dim as long ch = FB_CHAR_TO_INT( short_format(tmp) )
        if ( islower(ch) <> 0 ) then
            ch = toupper( ch )
		end if
        select case ( ch )
			case asc("D"):
				order_day = order_index
				got_sep = FALSE
			case asc("M"):
				order_month = order_index
				got_sep = FALSE
			case asc("Y"):
				order_year = order_index
				got_sep = FALSE
			case else:
				if ( got_sep = 0 ) then
					order_index += 1
				end if
				got_sep = TRUE
        end select
        tmp += 1
    wend

    if ( order_day = order_month orelse order_day = order_year orelse order_month = order_year ) then
        return FALSE
	end if
    if ( order_day > 2 orelse order_month > 2 orelse order_year > 2 ) then
        return FALSE
	end if

    if ( pOrderDay <> 0 ) then
        *pOrderDay = order_day
	end if
    if ( pOrderMonth <> 0 ) then
        *pOrderMonth = order_month
	end if
    if ( pOrderYear <> 0 ) then
        *pOrderYear = order_year
	end if

    return TRUE
end function

/':::::'/
private function InlineSelect( index as long, num1 as long, num2 as long, num3 as long ) as long
    if ( index = 0 ) then
        return num1
	end if
    if ( index = 1 ) then
        return num2
	end if
    if ( index = 2 ) then
        return num3
	end if
    return 0
end function

/':::::'/
function fb_hDateParse( text as const ubyte ptr, text_len as size_t, pDay as long ptr, pMonth as long ptr, pYear as long ptr, pLength as size_t ptr ) as long
    dim as size_t length = 0, _len = text_len
    dim as const ubyte ptr text_start = text
    dim as long result = FALSE
    dim as long _year = 1899, _month = 12, _day = 30
    dim as long order_year, order_month, order_day
    dim as ubyte ptr end_month

    if ( fb_hDateOrder( @order_day, @order_month, @order_year ) = 0 ) then
        /' switch to US date format '/
        order_month = 0
        order_day = 1
        order_year = 2
    end if

    /' skip white spaces '/
    while ( isspace( *text ) <> 0 )
        text += 1
	wend
    _len = text_len - (text - text_start)

    _month = fb_hFindMonth( text, _len, @end_month )
    if ( _month <> 0 ) then
        /' The string has the form: (MMMM|MMM) (d|dd)"," (yy|yyyy)  '/
        dim as ubyte ptr endptr
        text = end_month
        _day = strtol( cast(ubyte ptr, text), @endptr, 10 )
        if ( _day > 0 ) then

            /' skip white spaces '/
            text = endptr
            while ( isspace( *text ) <> 0 )
                text += 1
			wend

            if ( *text = asc(",") ) then
                dim as size_t year_size
                _year = strtol( cast(ubyte ptr, text + 1), @endptr, 10 )
                year_size = endptr - text
                if ( year_size > 0 ) then
                    if ( year_size = 2 ) then
                        _year += 1900
					end if

                    result = _day <= fb_hTimeDaysInMonth( _month, _year )
                    text = endptr
                end if
            end if
        end if
    else
        /' The string can be in the short or long format.
         *
         * The short format can be
         * [0-9]{1,2}(/|\-|\.)[0-9]{1,2}\1[0-9]{1,4}
         *                              ^^ reference to first divider
         *
         * The long format can have the form:
         * (d|dd) (MMMM|MM)"," (yy|yyyy)
         '/
        dim as size_t day_size
        dim as ubyte ptr endptr
        dim as long valid_divider
        _day = strtol( cast(ubyte ptr, text), @endptr, 10 )
        day_size = endptr - text
        if ( day_size <> 0 ) then
            dim as size_t month_size = 0
            dim as ubyte chDivider
            dim as long is_short_form

            /' skip white spaces '/
            text = endptr
            while ( isspace( *text ) <> 0 )
                text += 1
			wend

            /' read month and additional dividers '/
            chDivider = *text
            valid_divider = chDivider = asc("-") or chDivider = asc("/") or chDivider = asc(".")
            if ( chDivider = asc(".") ) then
                text += 1
                /' skip white spaces '/
                while ( isspace( *text ) <> 0 )
                    text += 1
				wend
                _len = text_len - (text - text_start)
                _month = fb_hFindMonth( text, _len, @end_month )
                /' We found a dot but a month name ... so this date
                 * is in LONG format. '/
                is_short_form = 0
				_month = 0
            elseif ( valid_divider <> 0 ) then
                text += 1
                is_short_form = TRUE
            else
                is_short_form = FALSE
            end if
            if ( is_short_form <> FALSE ) then
                /' short date '/
                /' skip white spaces '/
                while ( isspace( *text ) <> 0 )
                    text += 1
				wend
                _month = strtol( cast(ubyte ptr, text), @endptr, 10 )
                month_size = endptr - text
                if ( month_size <> 0 ) then
                    text = endptr
                    /' skip white spaces '/
                    while ( isspace( *text ) <> 0 )
                        text += 1
					wend
                    if ( *text = chDivider ) then
                        text += 1
                        result = TRUE
                    end if
                end if
            else
                /' long date '/
                _len = text_len - (text - text_start)
                _month = fb_hFindMonth( text, _len, @end_month )
                if ( _month <> 0 ) then
                    text = end_month
                    /' skip white spaces '/
                    while ( isspace( *text ) <> 0 )
                        text += 1
					wend
                    /' this comma is optional '/
                    if ( *text = asc(",") ) then
                        text += 1
                    end if
                    result = TRUE
                end if
            end if
            /' read year '/
            if ( result <> 0 ) then
                dim as size_t year_size
                /' skip white spaces '/
                while ( isspace( *text ) <> 0 )
                    text += 1
				wend
                _year = strtol( cast(ubyte ptr, text), @endptr, 10 )
                year_size = endptr - text
                if ( year_size > 0 ) then
                    /' adjust short form according to the date format '/
                    if ( is_short_form <> FALSE ) then
                        dim as long tmp_day = InlineSelect( order_day, _day, _month, _year )
                        dim as long tmp_month = InlineSelect( order_month, _day, _month, _year )
                        dim as long tmp_year = InlineSelect( order_year, _day, _month, _year )
                        year_size = InlineSelect( order_year, day_size, month_size, year_size )
                        _day = tmp_day
                        _month = tmp_month
                        _year = tmp_year
                        if ( _day < 1 or _month < 1 or _month > 12 ) then
                            result = FALSE
						end if
                    end if

                    if ( result <> 0 ) then
                        if ( year_size = 2 ) then
                            _year += 1900
						end if
                        result = _day <= fb_hTimeDaysInMonth( _month, _year )
                    end if
                    text = endptr
                else
                    result = FALSE
                end if
            end if
        end if
    end if

    if ( result <> 0 ) then
        /' Update used length '/
        length = text - text_start
    end if

    if ( result <> 0 ) then
        if ( pDay <> 0 ) then
            *pDay = _day
		end if
        if ( pMonth <> 0 ) then
            *pMonth = _month
		end if
        if ( pYear <> 0 ) then
            *pYear = _year
		end if
        if ( pLength <> 0 ) then
            *pLength = length
		end if
    end if

    return result
end function
end extern