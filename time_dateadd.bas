/' dateadd function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_DateAdd FBCALL ( interval as FBSTRING ptr, interval_value_arg as double, serial as double ) as double
    dim as long _year, _month, _day, _hour, _minute, _second
    dim as long carry_value, test_value
    dim as long interval_value = cast(long, fb_FIXDouble( interval_value_arg ))
    dim as long interval_type = fb_hTimeGetIntervalType( interval )

    fb_ErrorSetNum( FB_RTERROR_OK )

    fb_hTimeDecodeSerial ( serial, @_hour, @_minute, @_second, FALSE )
    fb_hDateDecodeSerial ( serial, @_year, @_month, @_day )

    select case ( interval_type )
		case FB_TIME_INTERVAL_YEAR:
			_year += interval_value
		case FB_TIME_INTERVAL_QUARTER:
			_month += interval_value * 3
		case FB_TIME_INTERVAL_MONTH:
			_month += interval_value
		case FB_TIME_INTERVAL_DAY, FB_TIME_INTERVAL_DAY_OF_YEAR, FB_TIME_INTERVAL_WEEKDAY:
			_day += interval_value
		case FB_TIME_INTERVAL_WEEK_OF_YEAR:
			_day += interval_value * 7
		case FB_TIME_INTERVAL_HOUR:
			_hour += interval_value
		case FB_TIME_INTERVAL_MINUTE:
			_minute += interval_value
		case FB_TIME_INTERVAL_SECOND:
			_second += interval_value
		case else:
			fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
    end select

    /' Normalize date/time '/
    select case ( interval_type )
		case FB_TIME_INTERVAL_WEEKDAY, FB_TIME_INTERVAL_DAY, FB_TIME_INTERVAL_DAY_OF_YEAR, FB_TIME_INTERVAL_SECOND, FB_TIME_INTERVAL_MINUTE, FB_TIME_INTERVAL_HOUR, FB_TIME_INTERVAL_WEEK_OF_YEAR:
			/' Nothing to do here because normalization will implicitly be done
			 * by the calculation of the new serial number. '/
		case FB_TIME_INTERVAL_QUARTER, FB_TIME_INTERVAL_YEAR, FB_TIME_INTERVAL_MONTH:
			/' Handle wrap-around for month '/
			if ( _month < 1 ) then
				carry_value = (_month - 12) \ 12
			else
				carry_value = (_month - 1) \ 12
			end if
			_year += carry_value
			_month -= carry_value * 12
			/' No wrap-around ... instead we must saturate the day '/
			test_value = fb_hTimeDaysInMonth( _month, _year )
			if ( _day > test_value ) then
				_day = test_value
			end if
    end select

    serial = fb_DateSerial( _year, _month, _day ) + fb_TimeSerial( _hour, _minute, _second )

    return serial
end function
end extern