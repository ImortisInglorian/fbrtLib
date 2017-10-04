extern "C"

declare function fb_Timer 					FBCALL ( ) as double
declare function fb_Time 					FBCALL ( ) as FBSTRING ptr
declare function fb_SetTime 				FBCALL ( _time as FBSTRING ptr ) as long
declare function fb_Date 					FBCALL ( ) as FBSTRING ptr
declare function fb_SetDate 				FBCALL ( _date as FBSTRING ptr ) as long

declare function fb_hSetTime 				cdecl  ( h as long, m as long, s as long ) as long
declare function fb_hSetDate 				cdecl  ( y as long, m as long, d as long ) as long


/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * VB-compatible functions
 *************************************************************************************************'/

enum eFbIntlIndex
	eFIL_DateDivider
    eFIL_TimeDivider
    eFIL_NumDecimalPoint
	eFIL_NumThousandsSeparator
end enum 

#define FB_WEEK_FIRST_SYSTEM            	0
#define FB_WEEK_FIRST_JAN_1             	1
#define FB_WEEK_FIRST_FOUR_DAYS         	2
#define FB_WEEK_FIRST_FULL_WEEK         	3
#define FB_WEEK_FIRST_DEFAULT           	FB_WEEK_FIRST_JAN_1

#define FB_WEEK_DAY_SYSTEM              	0
#define FB_WEEK_DAY_SUNDAY              	1
#define FB_WEEK_DAY_MONDAY              	2
#define FB_WEEK_DAY_TUESDAY             	3
#define FB_WEEK_DAY_WEDNESDAY           	4
#define FB_WEEK_DAY_THURSDAY            	5
#define FB_WEEK_DAY_FRIDAY              	6
#define FB_WEEK_DAY_SATURDAY            	7
#define FB_WEEK_DAY_DEFAULT             	FB_WEEK_DAY_SUNDAY

#define FB_TIME_INTERVAL_INVALID        	0
#define FB_TIME_INTERVAL_YEAR           	1
#define FB_TIME_INTERVAL_QUARTER        	2
#define FB_TIME_INTERVAL_MONTH          	3
#define FB_TIME_INTERVAL_DAY_OF_YEAR    	4
#define FB_TIME_INTERVAL_DAY            	5
#define FB_TIME_INTERVAL_WEEKDAY        	6
#define FB_TIME_INTERVAL_WEEK_OF_YEAR   	7
#define FB_TIME_INTERVAL_HOUR           	8
#define FB_TIME_INTERVAL_MINUTE         	9
#define FB_TIME_INTERVAL_SECOND         	10

#define fb_hTimeDaysInYear( _year ) 		(365 + fb_hTimeLeap( _year ))

declare function fb_IsDate 					FBCALL ( s as FBSTRING ptr ) as long
declare function fb_DateValue 				FBCALL ( s as FBSTRING ptr ) as long
declare function fb_DateSerial 				FBCALL ( _year as long, _month as long, _day as long ) as long
declare function fb_Year 					FBCALL ( serial as double ) as long
declare function fb_Month 					FBCALL ( serial as double ) as long
declare function fb_Day 					FBCALL ( serial as double ) as long
declare function fb_Weekday 				FBCALL ( serial as double, first_day_of_week as long ) as long

declare function fb_TimeValue 				FBCALL ( s as FBSTRING ptr ) as double
declare function fb_TimeSerial 				FBCALL ( _hour as long, _minute as long, _second as long ) as double
declare function fb_Hour 					FBCALL ( serial as double ) as long
declare function fb_Minute 					FBCALL ( serial as double ) as long
declare function fb_Second 					FBCALL ( serial as double ) as long

declare function fb_Now 					FBCALL ( ) as double

declare function fb_MonthName 				FBCALL ( _month as long, abbreviation as long ) as FBSTRING ptr
declare function fb_WeekdayName 			FBCALL ( _weekday as long, abbreviation as long, first_day_of_week as long ) as FBSTRING ptr

declare function fb_DateAdd 				FBCALL ( interval as FBSTRING ptr, interval_value_arg as double, serial as double ) as double
declare function fb_DatePart 				FBCALL ( interval as FBSTRING ptr, serial as double, first_day_of_week as long, first_day_of_year as long ) as long
declare function fb_DateDiff 				FBCALL ( interval as FBSTRING ptr, serial1 as double, serial2 as double, first_day_of_week as long, first_day_of_year as long ) as longint

declare function fb_hDateParse 				cdecl  ( text as ubyte const ptr, text_len as size_t, pDay as long ptr, pMonth as long ptr, pYear as long ptr, pLength as size_t ptr ) as long
declare function fb_DateParse 				FBCALL ( s as FBSTRING ptr, pDay as long ptr, pMonth as long ptr, pYear as long ptr ) as long
declare sub 	 fb_hDateDecodeSerial 		FBCALL ( serial as double, pYear as long ptr, pMonth as long ptr, pDay as long ptr )

declare function fb_hTimeParse 				cdecl  ( text as ubyte const ptr, text_len as size_t, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, pLength as size_t ptr ) as long
declare function fb_TimeParse 				FBCALL ( s as FBSTRING ptr, pHour as long ptr, pMinute as long ptr, pSecond as long ptr ) as long
declare sub 	 fb_hTimeDecodeSerial 		FBCALL ( serial as double, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, use_qb_hack as long )

declare function fb_DateTimeParse 			FBCALL ( s as FBSTRING ptr, pDay as long ptr, pMonth as long ptr, pYear as long ptr, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, want_date as long, want_time as long ) as long

declare sub 	 fb_I18nSet 				FBCALL ( on_off as long )
declare function fb_I18nGet 				FBCALL (  ) as long

declare function fb_hTimeLeap 				cdecl  ( _year as long ) as long
declare function fb_hGetDayOfYear 			cdecl  ( serial as double ) as long
declare function fb_hGetDayOfYearEx 		cdecl  ( _year as long, _month as long, _day as long ) as long
declare function fb_hGetWeekOfYear 			cdecl  ( ref_year as long, serial as double, first_day_of_year as long, first_day_of_week as long ) as long
declare function fb_hGetWeeksOfYear 		cdecl  ( ref_year as long, first_day_of_year as long, first_day_of_week as long ) as long
declare function fb_hTimeDaysInMonth 		cdecl  ( _month as long, _year as long ) as long
declare sub 	 fb_hNormalizeDate 			cdecl  ( pDay as long ptr, pMonth as long ptr, pYear as long ptr )
declare function fb_hTimeGetIntervalType 	cdecl  ( interval as FBSTRING ptr ) as long

declare function fb_IntlGet 				cdecl  ( index as eFbIntlIndex, disallow_localized as long ) as ubyte ptr
declare function fb_IntlGetDateFormat 		cdecl  ( buffer as ubyte ptr, _len as size_t, disallow_localized as long ) as long
declare function fb_IntlGetTimeFormat 		cdecl  ( buffer as ubyte ptr, _len as size_t, disallow_localized as long ) as long
declare function fb_IntlGetMonthName 		cdecl  ( _month as long, short_name as long, disallow_localized as long ) as FBSTRING ptr
declare function fb_IntlGetWeekdayName 		cdecl  ( _weekday as long, short_names as long, disallow_localized as long ) as FBSTRING ptr

declare function fb_DrvIntlGet 				cdecl  ( index as eFbIntlIndex ) as ubyte ptr
declare function fb_DrvIntlGetDateFormat 	cdecl  ( buffer as ubyte ptr, _len as size_t ) as long
declare function fb_DrvIntlGetTimeFormat 	cdecl  ( buffer as ubyte ptr, _len as size_t ) as long
declare function fb_DrvIntlGetMonthName  	cdecl  ( _month as long, short_name as long ) as FBSTRING ptr
declare function fb_DrvIntlGetWeekdayName 	cdecl  ( _weekday as long, short_names as long ) as FBSTRING ptr
end extern