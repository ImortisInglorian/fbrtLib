/' datepart function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_DatePart FBCALL ( interval as FBSTRING ptr, serial as double, first_day_of_week as long, first_day_of_year as long ) as long
	dim as long result = 0
	dim as long _year, _month, _day, _hour, _minute, _second
	dim as long interval_type = fb_hTimeGetIntervalType( interval )

	fb_ErrorSetNum( FB_RTERROR_OK )

	select case ( interval_type )
		case FB_TIME_INTERVAL_YEAR:
			fb_hDateDecodeSerial ( serial, @_year, NULL, NULL )
			result = _year
		case FB_TIME_INTERVAL_QUARTER:
			fb_hDateDecodeSerial ( serial, NULL, @_month, NULL )
			result = ((_month - 1) / 3) + 1
		case FB_TIME_INTERVAL_MONTH:
			fb_hDateDecodeSerial ( serial, NULL, @_month, NULL )
			result = _month
		case FB_TIME_INTERVAL_DAY_OF_YEAR:
			fb_hDateDecodeSerial ( serial, @_year, @_month, @_day )
			result = fb_hGetDayOfYearEx( _year, _month, _day )
		case FB_TIME_INTERVAL_DAY:
			fb_hDateDecodeSerial ( serial, NULL, NULL, @_day )
			result = _day
		case FB_TIME_INTERVAL_WEEKDAY:
			result = fb_Weekday( serial, first_day_of_week )
		case FB_TIME_INTERVAL_WEEK_OF_YEAR:
			fb_hDateDecodeSerial ( serial, @_year, NULL, NULL )
			result = fb_hGetWeekOfYear( _year, serial, first_day_of_year, first_day_of_week )
			if ( result < 0 ) then
				result = fb_hGetWeekOfYear( _year - 1, serial, first_day_of_year, first_day_of_week )
			end if
		case FB_TIME_INTERVAL_HOUR:
			fb_hTimeDecodeSerial ( serial, @_hour, NULL, NULL, FALSE )
			result = _hour
		case FB_TIME_INTERVAL_MINUTE:
			fb_hTimeDecodeSerial ( serial, NULL, @_minute, NULL, FALSE )
			result = _minute
		case FB_TIME_INTERVAL_SECOND:
			fb_hTimeDecodeSerial ( serial, NULL, NULL, @_second, FALSE )
			result = _second
		case else:
			fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end select

	return result
end function
end extern