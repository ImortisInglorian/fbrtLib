/' functions to decode a serial time number '/

#include "fb.bi"

extern "C"
/':::::'/
sub fb_hTimeDecodeSerial FBCALL ( serial as double, pHour as long ptr, pMinute as long ptr, pSecond as long ptr, use_qb_hack as long )
    dim as long _hour, _minute, _second
    dim as double dblFixValue = fb_FIXDouble( serial )

    serial -= dblFixValue
    if ( fb_hSign( serial ) = -1 ) then
        if ( use_qb_hack ) then
            /' Test for both 0.0 and -0.0 because FPUs may handle this as
             * different values ... '/
            if ( dblFixValue = 0.0 or dblFixValue = -0.0 ) then
                /' QB quirk ! '/
                serial = -serial
            else
                serial += 1
            end if
        else
            serial += 1
        end if
    end if

    /' The inaccuracies of the IEEE floating point data types ... '/
    serial += 0.000000001

    serial *= 24
    _hour = fix(serial)
    serial -= _hour
    serial *= 60
    _minute = fix(serial)
    serial -= _minute
    serial *= 60
    _second = fix(serial)

    if ( pHour <> NULL ) then
        *pHour = _hour
	end if
    if ( pMinute <> NULL ) then
        *pMinute = _minute
	end if
    if ( pSecond <> NULL ) then
        *pSecond = _second
	end if
end sub

function fb_Hour FBCALL ( serial as double ) as long
    dim as long _hour
    fb_hTimeDecodeSerial( serial, @_hour, NULL, NULL, TRUE )
    return _hour
end function

function fb_Minute FBCALL ( serial as double ) as long
    dim as long _minute
    fb_hTimeDecodeSerial( serial, NULL, @_minute, NULL, TRUE )
    return _minute
end function

function fb_Second FBCALL ( serial as double ) as long
    dim as long _second
    fb_hTimeDecodeSerial( serial, NULL, NULL, @_second, TRUE )
    return _second
end function
end extern