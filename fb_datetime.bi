declare function fb_Timer 					FBCALL ( ) as double
declare function fb_Time 					FBCALL ( ) as FBSTRING ptr
declare function fb_SetTime 				FBCALL ( _time as FBSTRING ptr ) as integer
declare function fb_Date 					FBCALL ( ) as FBSTRING ptr
declare function fb_SetDate 				FBCALL ( _date as FBSTRING ptr ) as integer

declare function fb_hSetTime 				cdecl  ( h as integer, m as integer, s as integer ) as integer
declare function fb_hSetDate 				cdecl  ( y as integer, m as integer, d as integer ) as integer


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

declare function fb_IsDate 					FBCALL ( s as FBSTRING ptr ) as integer
declare function fb_DateValue 				FBCALL ( s as FBSTRING ptr ) as integer
declare function fb_DateSerial 				FBCALL ( _year as integer, _month as integer, _day as integer ) as integer
declare function fb_Year 					FBCALL ( serial as double ) as integer
declare function fb_Month 					FBCALL ( serial as double ) as integer
declare function fb_Day 					FBCALL ( serial as double ) as integer
declare function fb_Weekday 				FBCALL ( serial as double, first_day_of_week as integer ) as integer

declare function fb_TimeValue 				FBCALL ( s as FBSTRING ptr ) as double
declare function fb_TimeSerial 				FBCALL ( _hour as integer, _minute as integer, _second as integer ) as double
declare function fb_Hour 					FBCALL ( serial as double ) as integer
declare function fb_Minute 					FBCALL ( serial as double ) as integer
declare function fb_Second 					FBCALL ( serial as double ) as integer

declare function fb_Now 					FBCALL ( ) as double

declare function fb_MonthName 				FBCALL ( _month as integer, abbreviation as integer ) as FBSTRING ptr
declare function fb_WeekdayName 			FBCALL ( _weekday as integer, abbreviation as integer, first_day_of_week as integer ) as FBSTRING ptr

declare function fb_DateAdd 				FBCALL ( interval as FBSTRING ptr, interval_value_arg as double, serial as double ) as double
declare function fb_DatePart 				FBCALL ( interval as FBSTRING ptr, serial as double, first_day_of_week as integer, first_day_of_year as integer ) as integer
declare function fb_DateDiff 				FBCALL ( interval as FBSTRING ptr, serial1 as double, serial2 as double, first_day_of_week as integer, first_day_of_year as integer ) as longint

declare function fb_hDateParse 				cdecl  ( text as ubyte const ptr, text_len as size_t, pDay as integer ptr, pMonth as integer ptr, pYear as integer ptr, pLength as size_t ptr ) as integer
declare function fb_DateParse 				FBCALL ( s as FBSTRING ptr, pDay as integer ptr, pMonth as integer ptr, pYear as integer ptr ) as integer
declare sub 	 fb_hDateDecodeSerial 		FBCALL ( serial as double, pYear as integer ptr, pMonth as integer ptr, pDay as integer ptr )

declare function fb_hTimeParse 				cdecl  ( text as ubyte const ptr, text_len as size_t, pHour as integer ptr, pMinute as integer ptr, pSecond as integer ptr, pLength as size_t ptr ) as integer
declare function fb_TimeParse 				FBCALL ( s as FBSTRING ptr, pHour as integer ptr, pMinute as integer ptr, pSecond as integer ptr ) as integer
declare sub 	 fb_hTimeDecodeSerial 		FBCALL ( serial as double, pHour as integer ptr, pMinute as integer ptr, pSecond as integer ptr, use_qb_hack as integer )

declare function fb_DateTimeParse 			FBCALL ( s as FBSTRING ptr, pDay as integer ptr, pMonth as integer ptr, pYear as integer ptr, pHour as integer ptr, pMinute as integer ptr, pSecond as integer ptr, want_date as integer, want_time as integer ) as integer

declare sub 	 fb_I18nSet 				FBCALL ( on_off as integer )
declare function fb_I18nGet 				FBCALL (  ) as integer

declare function fb_hTimeLeap 				cdecl  ( _year as integer ) as integer
declare function fb_hGetDayOfYear 			cdecl  ( serial as double ) as integer
declare function fb_hGetDayOfYearEx 		cdecl  ( _year as integer, _month as integer, _day as integer ) as integer
declare function fb_hGetWeekOfYear 			cdecl  ( ref_year as integer, serial as double, first_day_of_year as integer, first_day_of_week as integer ) as integer
declare function fb_hGetWeeksOfYear 		cdecl  ( ref_year as integer, first_day_of_year as integer, first_day_of_week as integer ) as integer
declare function fb_hTimeDaysInMonth 		cdecl  ( _month as integer, _year as integer ) as integer
declare sub 	 fb_hNormalizeDate 			cdecl  ( pDay as integer ptr, pMonth as integer ptr, pYear as integer ptr )
declare function fb_hTimeGetIntervalType 	cdecl  ( interval as FBSTRING ptr ) as integer

declare function fb_IntlGet 				cdecl  ( index as eFbIntlIndex, disallow_localized as integer ) as ubyte ptr
declare function fb_IntlGetDateFormat 		cdecl  ( buffer as ubyte ptr, _len as size_t, disallow_localized as integer ) as integer
declare function fb_IntlGetTimeFormat 		cdecl  ( buffer as ubyte ptr, _len as size_t, disallow_localized as integer ) as integer
declare function fb_IntlGetMonthName 		cdecl  ( _month as integer, short_name as integer, disallow_localized as integer ) as FBSTRING ptr
declare function fb_IntlGetWeekdayName 		cdecl  ( _weekday as integer, short_names as integer, disallow_localized as integer ) as FBSTRING ptr

declare function fb_DrvIntlGet 				cdecl  ( index as eFbIntlIndex ) as ubyte ptr
declare function fb_DrvIntlGetDateFormat 	cdecl  ( buffer as ubyte ptr, _len as size_t ) as integer
declare function fb_DrvIntlGetTimeFormat 	cdecl  ( buffer as ubyte ptr, _len as size_t ) as integer
declare function fb_DrvIntlGetMonthName  	cdecl  ( _month as integer, short_name as integer ) as FBSTRING ptr
declare function fb_DrvIntlGetWeekdayName 	cdecl  ( _weekday as integer, short_names as integer ) as FBSTRING ptr
