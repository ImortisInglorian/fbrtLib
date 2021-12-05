/' get i18n data '/

#include "../fb.bi"
#include "langinfo.bi"

Function fb_DrvIntlGet( eFbIntlIndex Index ) as const ubyte ptr

	select case Index
		case eFIL_DateDivider
			return "/"
		case eFIL_TimeDivider
			return ":"
		case eFIL_NumDecimalPoint
			return nl_langinfo( RADIXCHAR )
		case eFIL_NumThousandsSeparator
			return nl_langinfo( THOUSEP )
	end select
	return NULL
End Function
