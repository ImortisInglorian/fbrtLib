/' get file date/time by filename '/

/'
!!! FIXME !!! - update the crt headers
- have issues here with duplicate definitions in the crt headers
- need to update crt headers to allow these includes to work together
'/

#include "fb.bi"
#include "crt/time.bi"
#include "crt/sys/stat.bi"

extern "C"
function fb_FileDateTime FBCALL ( filename as const ubyte ptr ) as double
	dim as stat buf
	if ( _stat( filename, @buf ) <> 0 ) then
		return 0.0
	end if

	dim as tm ptr _tm = localtime( @buf.st_mtime )
	if ( @_tm = NULL ) then
		return 0.0
	end if

	return fb_DateSerial( 1900 + _tm->tm_year, 1+_tm->tm_mon, _tm->tm_mday ) + fb_TimeSerial( _tm->tm_hour, _tm->tm_min, _tm->tm_sec )
end function
end extern