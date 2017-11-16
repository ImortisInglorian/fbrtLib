/' console COLOR statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

dim shared as long colorlut(0 to 15) = { FB_COLOR_BLACK, FB_COLOR_BLUE, _
													  FB_COLOR_GREEN, FB_COLOR_CYAN, _
													  FB_COLOR_RED, FB_COLOR_MAGENTA, _
													  FB_COLOR_BROWN, FB_COLOR_WHITE, _
													  FB_COLOR_GREY, FB_COLOR_LBLUE, _
													  FB_COLOR_LGREEN, FB_COLOR_LCYAN, _
													  FB_COLOR_LRED, FB_COLOR_LMAGENTA, _
													  FB_COLOR_YELLOW, FB_COLOR_BWHITE }

dim shared as long last_bc = FB_COLOR_BLACK, last_fc = FB_COLOR_WHITE

extern "C"
sub fb_ConsoleColorEx( hConsole as HANDLE, fc as long, bc as long )
	dim as long last_attr = fb_ConsoleGetColorAttEx( hConsole )
	dim as long last_bc = (last_attr shr 4) and &hF
	dim as long last_fc = (last_attr and &hF)

	if ( fc >= 0 ) then
		fc = colorlut(fc and 15)
	else
		fc = last_fc
	end if

	if ( bc >= 0 ) then
		bc = colorlut(bc and 15)
	else
		bc = last_bc
	end if

	SetConsoleTextAttribute( hConsole, fc + (bc shl 4) )
end sub

function fb_ConsoleColor( fc as long, bc as long, flags as long ) as long
	dim as long cur = last_fc or (last_bc shl 16)

	if ( not( flags and FB_COLOR_FG_DEFAULT ) ) then
		last_fc = (fc and &hF)
		fc = colorlut(last_fc)
	else
		fc = last_fc
	end if

	if ( not( flags and FB_COLOR_BG_DEFAULT ) ) then
		last_bc = (bc and &hF)
		bc = colorlut(last_bc)
	else
		bc = last_bc
	end if

	SetConsoleTextAttribute( __fb_out_handle, fc + (bc shl 4) )

	return cur
end function

function fb_ConsoleGetColorAttEx( hConsole as HANDLE ) as long
	dim as CONSOLE_SCREEN_BUFFER_INFO info
	if ( GetConsoleScreenBufferInfo( hConsole, @info ) = 0 ) then
		return 7
	end if
	return info.wAttributes
end function

function fb_ConsoleGetColorAtt( ) as long
	return fb_ConsoleGetColorAttEx( __fb_out_handle )
end function
end extern