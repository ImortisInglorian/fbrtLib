/' sleep() function '/

#include "fb.bi"

extern "C"
sub fb_ConsoleSleep( msecs as long )
#if defined( HOST_XBOX )
    /' NOTE: No need to test for input keys because sleep will be hooked
     *       when the application is switched to graphics mode and the
     *       console implementations for keyboard handling are only dummy
     *       functions.
     '/
	fb_Delay( msecs )
#else
	/' infinite? wait until any key is pressed '/
	if ( msecs = -1 ) then
		while( fb_hConsoleInputBufferChanged( ) = 0 )
			fb_Delay( 50 )
		wend
		exit sub
	end if

	/' if above n-mili-seconds, check for key input, otherwise,
	   don't screw the precision with slow console checks '/
	if ( msecs >= 100 ) then
		while( msecs > 50 )
			if ( fb_hConsoleInputBufferChanged( ) <> 0 ) then
				exit while
			end if

			fb_Delay( 50 )
			msecs -= 50
		wend
	end if

	if ( msecs >= 0 ) then
		fb_Delay( msecs )
	end if
#endif
end sub
end extern