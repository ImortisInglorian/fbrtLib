/' returns the month name '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_MonthName FBCALL ( _month as long, abbreviation as long ) as FBSTRING ptr
    dim as FBSTRING ptr res

    if ( _month < 1 or _month > 12 ) then
        fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
        return @__fb_ctx.null_desc
    end if

    fb_ErrorSetNum( FB_RTERROR_OK )

    res = fb_IntlGetMonthName( _month, abbreviation, FALSE )
    if ( res = NULL ) then
		fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
		res = @__fb_ctx.null_desc
    end if

    return res
end function
end extern