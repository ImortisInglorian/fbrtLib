#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_hSetDate( y as long, m as long, d as long ) as long
	/' get current local time and date '/
	dim as SYSTEMTIME st
	GetLocalTime( @st )

	/' set time fields '/
	st.wYear = y
	st.wMonth = m
	st.wDay = d

	/' set system time relative to local time zone '/
	if ( SetLocalTime( @st ) = 0) then
		return -1
	end if

	/' send WM_TIMECHANGE to all top-level windows on NT and 95/98/Me
	 * (_not_ on 2K/XP etc.) '/
	/' if ((GetVersion() & 0xFF) == 4)
		SendMessage(HWND_BROADCAST, WM_TIMECHANGE, 0, 0); '/

	return 0
end function
end extern