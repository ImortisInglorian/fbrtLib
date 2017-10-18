/' console INKEY() function '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
/' Caller is expected to hold FB_LOCK() '/
function fb_ConsoleInkey( ) as FBSTRING ptr
	dim as FBSTRING ptr res
	dim as long key

	key = fb_hConsoleGetKey( TRUE )

	if ( key = -1 ) then
		res = @__fb_ctx.null_desc
	else
		res = fb_hMakeInkeyStr( key )
	end if

	return res
end function

/' Doing synchronization manually here because getkey() is blocking '/
function fb_ConsoleGetkey( ) as long
	dim as long k

	do
		FB_LOCK( )
		k = fb_hConsoleGetKey( TRUE )
		FB_UNLOCK( )

		if ( k <> -1 ) then
			exit do
		end if

		fb_Sleep( -1 )
	loop while( 1 )

	return k
end function

/' Caller is expected to hold FB_LOCK() '/
function fb_ConsoleKeyHit( ) as long
    return fb_hConsolePeekKey( TRUE ) <> -1
end function
end extern