/' console pcopy function '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsolePageCopy( src as long, dst as long ) as long
	fb_hConsoleGetHandle( FALSE )

	/' use current? '/
	if ( src < 0 ) then
		src = __fb_con.active
	end if

	/' not allocated yet? '/
	if ( __fb_con.pgHandleTb(src) = NULL ) then
		dim as HANDLE hnd = fb_hConsoleCreateBuffer( )
		if ( hnd = NULL ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		else
			__fb_con.pgHandleTb(src) = hnd
		end if
	end if

	/' use current? '/
	if ( dst < 0 ) then
		dst = __fb_con.visible
	end if

	if ( src = dst ) then
		return fb_ErrorSetNum( FB_RTERROR_OK )
	end if

	/' not allocated yet? '/
	if ( __fb_con.pgHandleTb(dst) = NULL ) then
		dim as HANDLE hnd = fb_hConsoleCreateBuffer( )
		if ( hnd = NULL ) then
			return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
		else
			__fb_con.pgHandleTb(dst) = hnd
		end if
	end if

	dim as CONSOLE_SCREEN_BUFFER_INFO csbi
	GetConsoleScreenBufferInfo( __fb_con.pgHandleTb(src), @csbi )
	dim as PCHAR_INFO buff = allocate( csbi.dwSize.X * csbi.dwSize.Y * sizeof( CHAR_INFO ) )
	if( buff <> NULL ) then
		dim as COORD _pos = ( 0, 0 )
		ReadConsoleOutput( __fb_con.pgHandleTb(src), buff, csbi.dwSize, _pos, @csbi.srWindow )

		GetConsoleScreenBufferInfo( __fb_con.pgHandleTb(dst), @csbi )
		WriteConsoleOutput( __fb_con.pgHandleTb(dst), buff, csbi.dwSize, _pos, @csbi.srWindow )
		deallocate( buff )
	end if

	return fb_ErrorSetNum( iif( buff <> NULL, FB_RTERROR_OK, FB_RTERROR_OUTOFMEMORY ) )
end function
end extern