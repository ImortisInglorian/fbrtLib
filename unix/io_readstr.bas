/' console line input function '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleReadStr( buffer as ubyte ptr, len_ as size_t ) As ubyte ptr

	dim as long k, x, y, cols
	dim pos_ as ssize_t = 0
	dim ch(0 to 1) as ubyte = { 0, 0 }

	if (__fb_con.inited = 0) then
		return fgets(buffer, len_, stdin)
	end if

	fb_ConsoleGetSize(@cols, NULL)

	do
		do 
			k = fb_hGetCh(TRUE)
			if( (k = -1) orelse (k > &HFF) ) then
				fb_Delay( 10 )
			else
				exit do
			end if
		loop while (true)

		fb_ConsoleGetXY(@x, @y)

		if (k = 8) then
			if (pos_ > 0) then
				x -= 1
				if (x <= 0) then
					x = cols
					y -= 1
					if (y <= 0) then
						x = y = 1
					end if
				end if
				fb_hTermOut(SEQ_LOCATE, x-1, y-1)
				fb_hTermOut(SEQ_DEL_CHAR, 0, 0)
				pos_ -= 1
			end if
		elseif (k <> asc(!"\t")) then
			if (pos_ < len_ - 1) then
				ch(0) = k
				buffer[pos_] = k
				pos_ += 1
				fb_ConsolePrintBuffer(@ch(0), 0)
				if (x = cols) then
					fputc( asc(!"\n"), stdout )
				end if
			end if
		end if
	Loop while (k <> asc(!"\r"))

	fputc( asc(!"\n"), stdout )
	buffer[pos_] = 0

	return buffer
End Function
End Extern
