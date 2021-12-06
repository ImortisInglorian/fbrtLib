/' low-level print to console function '/

#include "../fb.bi"
#include "fb_private_console.bi"

#define CTRL_ALWAYS &h0800D101
#define ENTER_UTF8  !"\&h1b%G"
#define EXIT_UTF8   !"\&h1b%@"

Extern "c"
Sub fb_ConsolePrintBufferEx( buffer as const any ptr, len_ as size_t, mask as long )

	dim as size_t avail, avail_len
	dim cbuffer as const ubyte ptr = cast(const ubyte ptr, buffer)
	dim c as ulong

	if (__fb_con.inited = 0) then
		fwrite(cast(any ptr, buffer), len_, 1, stdout)
		fflush(stdout)
		Exit Sub
	end if

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	/' ToDo: handle scrolling for internal characters/attributes buffer? '/
	avail = (__fb_con.w * __fb_con.h) - (((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1)
	avail_len = len_
	if (avail < avail_len) then
		avail_len = avail
	end if
	memcpy(__fb_con.char_buffer + ((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1, buffer, avail_len)
	memset(__fb_con.attr_buffer + ((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1, __fb_con.fg_color Or (__fb_con.bg_color Shl 4), avail_len)

	while len_ <> 0
		c = *cbuffer
		if( c = 0 ) then
			c = 32
		end if

		if (c < 32) then
			if ((CTRL_ALWAYS Shr c) And &h1) then
				/' This character can't be printed, we must use unicode
				 * Enter UTF-8 and start constructing 0xF000 code
				 '/
				fputs( ENTER_UTF8 !"\&hEF\&h80", stdout )
				/' Set the last 6 bits '/
				fputc( c Or &h80, stdout )
				/' Escape UTF-8 '/
				fputs( EXIT_UTF8, stdout )
			else
				fputc( c, stdout )
			end if
		else
			fputc( c, stdout )
		end if

		__fb_con.cur_x += 1
		if ((c = 10) OrElse (__fb_con.cur_x >= __fb_con.w)) then
			__fb_con.cur_x = 1
			__fb_con.cur_y += 1
			if (__fb_con.cur_y > __fb_con.h) then
				__fb_con.cur_y = __fb_con.h
			end if
		end if
		len_ -= 1
		cbuffer += 1
	wend

	fflush( stdout )
End Sub

Sub fb_ConsolePrintBuffer( buffer as const ubyte ptr, mask as long )

	fb_ConsolePrintBufferEx( buffer, strlen(buffer), mask )
End Sub
End Extern
