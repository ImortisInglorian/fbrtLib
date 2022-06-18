/' console COLOR statement '/

#include "../fb.bi"
#include "fb_private_console.bi"

Extern "c"
Function fb_ConsoleColor( fc as ulong, bc as ulong, flags as long ) As uLong

	dim map(0 to 7) as ubyte = { 0, 4, 2, 6, 1, 5, 3, 7 }
	dim old_fg as long = __fb_con.fg_color
	dim old_bg as long = __fb_con.bg_color
	dim force as Boolean = FALSE

	if (__fb_con.inited = 0) then
		return old_fg or (old_bg shl 16)
	end if

	if (flags And FB_COLOR_FG_DEFAULT) = 0 Then
		__fb_con.fg_color = (fc And &HF)
	end if
	if (flags And FB_COLOR_BG_DEFAULT) = 0 Then
		__fb_con.bg_color = (bc And &HF)
	end if

	if ((__fb_con.inited = INIT_CONSOLE) orelse (__fb_con.term_type <> TERM_XTERM)) then
		/' console and any terminal but xterm do not support extended color attributes and only allow 16+8 colors '/
		if (__fb_con.fg_color <> old_fg) then
			if ((__fb_con.fg_color xor old_fg) And &h8) <> 0 then
				/' bright mode changed: reset attributes and force setting both back and fore colors '/
				fb_hTermOut(SEQ_RESET_COLOR, 0, 0)
				if (__fb_con.fg_color And &h8) <> 0 then
					fb_hTermOut(SEQ_BRIGHT_COLOR, 0, 0)
				end if
				force = TRUE
			end if
			fb_hTermOut(SEQ_FG_COLOR, 0, map(__fb_con.fg_color And &H7))
		end if
		if ((__fb_con.bg_color <> old_bg) orelse (force)) then
			fb_hTermOut(SEQ_BG_COLOR, 0, map(__fb_con.bg_color And &H7))
		end if
	else
		/' generic xterm supports 16+16 colors '/
		if (__fb_con.fg_color <> old_fg) then
			fb_hTermOut(SEQ_SET_COLOR_EX, map(__fb_con.fg_color And &H7) + (Iif(__fb_con.fg_color And &H8, 90, 30)), 0)
		end if
		if (__fb_con.bg_color <> old_bg) then
			fb_hTermOut(SEQ_SET_COLOR_EX, map(__fb_con.bg_color And &H7) + (Iif(__fb_con.bg_color And &H8, 100, 40)), 0)
		end if
	end if

	return old_fg or (old_bg shl 16)
End Function

Function fb_ConsoleGetColorAtt( ) As uLong

	return Iif(__fb_con.inited, (__fb_con.fg_color Or (__fb_con.bg_color shl 4)), &h7)
End Function
End Extern
