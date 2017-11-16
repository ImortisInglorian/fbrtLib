/' console SCREEN() function (character/color query) '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"
function fb_ConsoleReadXY FBCALL ( col as long, row as long, colorflag as long ) as ulong
	dim as TCHAR character
	dim as WORD attribute
	dim as DWORD res
	dim as COORD coord

	fb_hConvertToConsole( @col, @row, NULL, NULL )

	coord.X = cast(SHORT, col)
	coord.Y = cast(SHORT, row)

	if ( colorflag ) then
		ReadConsoleOutputAttribute( __fb_out_handle, @attribute, 1, coord, @res)
		return (cast(ulong, attribute)) and &hfffful
	else
		ReadConsoleOutputCharacter( __fb_out_handle, @character, 1, coord, @res)
		return (cast(ulong, character)) and iif(sizeof(TCHAR) = 1, &hfful, &hfffful)
	end if
end function
end extern