/' console INKEY() function '/

#include "../fb.bi"
#include "fb_private_console.bi"
#include "../destruct_string.bi"

extern "C"
/' Caller is expected to hold FB_LOCK() '/
function fb_ConsoleInkey( result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string dst
	dim as long key

	key = fb_hConsoleGetKey( TRUE )

	if ( key <> -1 ) then
		fb_hMakeInkeyStr( key, @dst )
	end if

	fb_StrSwapDesc( result, @dst )
	return result
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