/' parse a string time '/

#include "fb.bi"
#include "crt/ctype.bi"

extern "C"
/':::::'/
private function fb_hCheckAMPM( text as const ubyte ptr, pLength as size_t ptr ) as long
    dim as const ubyte ptr text_start = text
    dim as long result = 0

    /' skip WS '/
    while ( isspace( *text ) <> 0 )
        text += 1
	wend

    select case ( *text )
		case asc("a"), asc("A"):
			result = 1
			text += 1
		case asc("p"), asc("P"):
			result = 2
			text += 1
    end select
    if ( result <> 0 ) then
        dim as ubyte ch = *text
        if ( ch = 0 ) then
            ' ignore
        elseif ( ch = asc("m") or ch = asc("M") ) then
            ' everything's fine
            text += 1
        else
            result = 0
        end if
    end if
    if ( result <> 0 ) then
        if ( isalpha( *text ) <> 0 ) then
            result = 0
		end if
    end if
    if ( result <> 0 ) then
        /' skip WS '/
        while ( isspace( *text ) <> 0 )
            text += 1
		wend
        if ( pLength <> 0 ) then
            *pLength = text - text_start
		end if
    end if
    return result
end function

/':::::'/
function fb_hTimeParse( text as const ubyte ptr, text_len as size_t, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, pLength as size_t ptr ) as long
    dim as size_t length = 0
    dim as const ubyte ptr text_start = text
    dim as long am_pm = 0
    dim as long result = FALSE
    dim as long _hour = 0, _minute = 0, _second = 0
    dim as ubyte ptr endptr

    _hour = strtol( text, @endptr, 10 )
    if ( _hour >= 0 and _hour < 24 and endptr <> text) then
        dim as long is_ampm_hour = ( _hour >= 1 and _hour <= 12 )
        /' skip white spaces '/
        text = endptr
        while ( isspace( *text ) <> 0 )
            text += 1
		wend
        if ( *text= asc(":") ) then
            text += 1
            _minute = strtol( text, @endptr, 10 )
            if ( _minute >= 0 and _minute < 60 and endptr <> text ) then
                text = endptr
                while ( isspace( *text ) <> 0 )
                    text += 1
				wend

                result = TRUE
                if ( *text = asc(":") ) then
                    text += 1
                    _second = strtol( text, @endptr, 10 )
                    if ( endptr <> text ) then
                        if( _second < 0 or _second > 59 ) then
                            result = FALSE
                        else
                            text = endptr
                        end if
                    else
                        result = FALSE
                    end if
                end if
                if ( result <> 0 and is_ampm_hour <> 0 ) then
                    am_pm = fb_hCheckAMPM( text, @length )
                    if ( am_pm <> 0 ) then
                        text += length
                    end if
                end if
            end if
        elseif ( is_ampm_hour <> 0 ) then
            am_pm = fb_hCheckAMPM( text, @length )
            if ( am_pm <> 0 ) then
                text += length
                result = TRUE
            end if
        end if
    end if
    if ( result <> 0 ) then
        if ( am_pm <> 0 ) then
            /' test for AM/PM '/
            if ( _hour = 12 ) then
                if ( am_pm = 1 ) then
                    _hour -= 12
				end if
            else
                if ( am_pm = 2 ) then
                    _hour += 12
				end if
            end if
        end if
        /' Update used length '/
        length = text - text_start
    end if

    if ( result <> 0 ) then
        if ( pHour <> 0 ) then
            *pHour = _hour
		end if
        if ( pMinute <> 0 ) then
            *pMinute = _minute
		end if
        if ( pSecond <> 0 ) then
            *pSecond = _second
		end if
        if ( pLength <> 0 ) then
            *pLength = length
		end if
    end if

    return result
end function
end extern