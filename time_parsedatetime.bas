/' parse a string containing a date and/or time '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
/':::::'/
function fb_DateTimeParse FBCALL ( s as FBSTRING ptr, pDay as long ptr, pMonth as long ptr, pYear as long ptr, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, want_date as long, want_time as long) as long
    dim as ubyte ptr text
    dim as long result = FALSE
    dim as size_t length, text_len

    text = s->data
    if ( text = NULL ) then
        return result
    end if

    text_len = FB_STRSIZE( s )

    if ( fb_hDateParse( text, text_len, pDay, pMonth, pYear, @length ) ) then
        text += length
        text_len -= length

        /' skip WS '/
        while( isspace( *text ) <> 0 )
            text += 1
			text_len -= 1
		wend
        /' skip optional comma '/
        if ( *text = asc(",") ) then
            text += 1
			text_len -= 1
		end if

        if ( fb_hTimeParse( text, text_len, pHour, pMinute, pSecond, @length ) ) then
            text += length
            text_len -= length
            result = TRUE
        elseif ( want_time = 0 ) then
            result = TRUE
        end if
    elseif ( fb_hTimeParse( text, text_len, pHour, pMinute, pSecond, @length ) ) then
        text += length
        text_len -= length

        /' skip WS '/
        while( isspace( *text ) <> 0 )
            text += 1
			text_len -= 1
		wend
        /' skip optional comma '/
        if ( *text = asc(",") ) then
            text += 1
			text_len -= 1
		end if

        if ( fb_hDateParse( text, text_len, pDay, pMonth, pYear, @length ) ) then
            text += length
            text_len -= length
            result = TRUE
        elseif ( want_date = 0 ) then
            result = TRUE
        end if
    end if

    if ( result <> 0 ) then
        /' the rest of the text must consist of white spaces '/
        while ( *text <> 0 )
            dim ch as ubyte = *text
            text += 1
            if ( isspace( ch ) = 0 ) then
                result = FALSE
                exit while
            end if
        wend
    end if

    return result
end function

/':::::'/
function fb_DateParse FBCALL ( s as FBSTRING ptr, pDay as long ptr, pMonth as long ptr, pYear as long ptr ) as long
    return fb_DateTimeParse( s, pDay, pMonth, pYear, NULL, NULL, NULL, TRUE, FALSE )
end function

/':::::'/
function fb_TimeParse FBCALL ( s as FBSTRING ptr, pHour as long ptr, pMinute as long ptr, pSecond as long ptr ) as long
    return fb_DateTimeParse( s, NULL, NULL, NULL, pHour, pMinute, pSecond, FALSE, TRUE )
end function
end extern