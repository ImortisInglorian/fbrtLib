/' timeserial function '/

#include "fb.bi"

extern "C"
/':::::'/
function fb_TimeSerial FBCALL ( _hour as long, _minute as long, _second as long ) as double
    dim as double dblHour = 1.0 * cast(double, _hour) / 24.0
    dim as double dblMinute = 1.0 * _minute / (24.0 * 60.0)
    dim as double dblSecond = 1.0 * _second / (24.0 * 60.0 * 60.0)
    return dblHour + dblMinute + dblSecond
end function
end extern