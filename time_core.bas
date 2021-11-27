/' core time/date functions '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_hTimeLeap( _year as long ) as long
    if ( ( _year mod 400 ) = 0 ) then
        return 1
	end if
    if ( ( _year mod 100 ) = 0 ) then
        return 0
	end if
    return iif( ( ( _year and 3 ) = 0 ), 1, 0 )
end function

/':::::'/
function fb_hTimeDaysInMonth( _month as long, _year as long ) as long
    static as long days(0 to 11) = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    DBG_ASSERT(_month >= 1 andalso _month <= 12 )
    if ( _month = 2 ) then
        return days(_month-1) + fb_hTimeLeap( _year )
	end if
    return days(_month-1)
end function

/':::::'/
sub fb_hNormalizeDate( pDay as long ptr, pMonth as long ptr, pYear as long ptr )
    DBG_ASSERT( pDay <>NULL )
    DBG_ASSERT( pMonth <> NULL )
    DBG_ASSERT( pYear <> NULL )
    scope
        dim as long _day = *pDay
        dim as long _month = *pMonth
        dim as long _year = *pYear
        if ( _month < 1 ) then
            dim as long sub_months = -_month + 1
            dim as long sub_years = (sub_months + 11) \ 12
            _year -= sub_years
            _month = sub_years * 12 - sub_months + 1
        else
            _month -= 1
            _year += _month \ 12
            _month mod= 12
            _month += 1
        end if

        if ( _day < 1 ) then
            dim as long sub_days = -_day + 1
            while (sub_days > 0) 
                dim as long dom
                _month -= 1
                if ( _month = 0 ) then
                    _month = 12
                    _year -= 1
                end if
                dom = fb_hTimeDaysInMonth( _month, _year )
                if ( sub_days > dom ) then
                    sub_days -= dom
                else
                    _day = dom - sub_days + 1
                    sub_days = 0
                end if
            wend
        else
            dim as long dom = fb_hTimeDaysInMonth( _month, _year )
            while( _day > dom )
                _day -= dom
                _month += 1
                if ( _month = 13 ) then
                    _month = 1
                    _year += 1
                end if
                dom = fb_hTimeDaysInMonth( _month, _year )
            wend
        end if
        *pDay = _day
        *pMonth = _month
        *pYear = _year
    end scope
end sub

/':::::'/
function fb_hTimeGetIntervalType( interval as FBSTRING ptr ) as long
	dim as long result = FB_TIME_INTERVAL_INVALID

    if ( interval <> NULL andalso interval->data <> NULL ) then
        if ( strcmp( interval->data, "yyyy" ) = 0 ) then
            result = FB_TIME_INTERVAL_YEAR
        elseif ( strcmp( interval->data, "q" ) = 0 ) then
            result = FB_TIME_INTERVAL_QUARTER
        elseif ( strcmp( interval->data, "m" ) = 0 ) then
            result = FB_TIME_INTERVAL_MONTH
        elseif ( strcmp( interval->data, "y" ) = 0 ) then
            result = FB_TIME_INTERVAL_DAY_OF_YEAR
        elseif ( strcmp( interval->data, "d" ) = 0 ) then
            result = FB_TIME_INTERVAL_DAY
        elseif ( strcmp( interval->data, "w" ) = 0 ) then
            result = FB_TIME_INTERVAL_WEEKDAY
        elseif ( strcmp( interval->data, "ww" ) = 0 ) then
            result = FB_TIME_INTERVAL_WEEK_OF_YEAR
        elseif ( strcmp( interval->data, "h" ) = 0 ) then
            result = FB_TIME_INTERVAL_HOUR
        elseif ( strcmp( interval->data, "n" ) = 0 ) then
            result = FB_TIME_INTERVAL_MINUTE
        elseif ( strcmp( interval->data, "s" ) = 0 ) then
            result = FB_TIME_INTERVAL_SECOND
        end if
    end if

    return result
end function
end extern