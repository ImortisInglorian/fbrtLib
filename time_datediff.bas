/' datediff function '/

#include "fb.bi"
#include "crt/math.bi"

extern "C"
/':::::'/
function fb_DateDiff FBCALL ( interval as FBSTRING ptr, serial1 as double, serial2 as double, first_day_of_week as long, first_day_of_year as long ) as longint
	dim as long year1, month1, _hour, _minute, _second, week
	dim as long year2, month2
	dim as longint result = 0
	dim as double serial
	dim as long interval_type = fb_hTimeGetIntervalType( interval )

	fb_ErrorSetNum( FB_RTERROR_OK )

	select case ( interval_type )
		case FB_TIME_INTERVAL_YEAR:
			fb_hDateDecodeSerial ( serial1, @year1, NULL, NULL )
			fb_hDateDecodeSerial ( serial2, @year2, NULL, NULL )
			result = year2 - year1
		case FB_TIME_INTERVAL_QUARTER,FB_TIME_INTERVAL_MONTH:
			fb_hDateDecodeSerial ( serial1, @year1, @month1, NULL )
			fb_hDateDecodeSerial ( serial2, @year2, @month2, NULL )
			result = (month2 - month1) + (year2 - year1) * 12
			if ( interval_type = FB_TIME_INTERVAL_QUARTER ) then
				result = result / 3
			end if
		case FB_TIME_INTERVAL_DAY_OF_YEAR, FB_TIME_INTERVAL_DAY:
			result = cast(longint, (floor(serial2) - floor(serial1)))
		case FB_TIME_INTERVAL_WEEKDAY, FB_TIME_INTERVAL_WEEK_OF_YEAR:
			fb_hDateDecodeSerial ( serial1, @year1, NULL, NULL )
			week = fb_hGetWeekOfYear( year1, serial1, first_day_of_year, first_day_of_week )
			result = fb_hGetWeekOfYear( year1, serial2, first_day_of_year, first_day_of_week )
			if ( week > 0 ) then
				week -= 1
			end if
			if ( result > 0 ) then
				result -= 1
			end if
			result -= week
			if ( interval_type = FB_TIME_INTERVAL_WEEKDAY ) then
				dim as long add_value
				if ( serial1 > serial2 ) then
					dim as double serial_tmp = serial1
					serial1 = serial2
					serial2 = serial_tmp
					add_value = 1
				else
					add_value = -1
				end if
				if ( fb_Weekday( serial1, first_day_of_week ) > fb_Weekday( serial2, first_day_of_week ) ) then
					result += add_value
				end if
			end if
		case FB_TIME_INTERVAL_HOUR:
			serial = serial2 - serial1
			fb_hTimeDecodeSerial ( serial, @_hour, NULL, NULL, FALSE )
			result = cast(longint, (_hour + floor(serial) * 24.0))
		case FB_TIME_INTERVAL_MINUTE:
			serial = serial2 - serial1
			fb_hTimeDecodeSerial ( serial, @_hour, @_minute, NULL, FALSE )
			result = cast(longint, (_minute + (_hour + floor(serial) * 24.0) * 60.0))
		case FB_TIME_INTERVAL_SECOND:
			serial = serial2 - serial1
			fb_hTimeDecodeSerial ( serial, @_hour, @_minute, @_second, FALSE )
			result = cast(longint, (_second + (_minute + (_hour + floor(serial) * 24.0) * 60.0) * 60.0))
		case else:
			fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
	end select

	return result
end function
end extern