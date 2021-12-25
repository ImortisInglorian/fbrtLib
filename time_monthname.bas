/' returns the month name '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
/':::::'/
function fb_MonthName FBCALL ( _month as long, abbreviation as long, result as FBSTRING ptr ) as FBSTRING ptr
    dim as destructable_string tmp_str
    dim as long err = FB_RTERROR_ILLEGALFUNCTIONCALL

    DBG_ASSERT( result <> NULL )

    if ( _month >= 1 andalso _month <= 12 ) then

        err = FB_RTERROR_OK

        if ( fb_IntlGetMonthName( _month, abbreviation, FALSE, @tmp_str ) = NULL ) then
            err = FB_RTERROR_ILLEGALFUNCTIONCALL
        end if
    end if

    fb_StrSwapDesc( @tmp_str, result )
    fb_ErrorSetNum( err )
    return result
end function
end extern