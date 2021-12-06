/' low-level print to console function '/

#include "../fb.bi"
#include "fb_private_console.bi"

#define ENTER_UTF8  !"\&h1b%G"
#define EXIT_UTF8   !"\&h1b%@"

Extern "c"
Sub fb_ConsolePrintBufferWstrEx( buffer as const FB_WCHAR ptr, chars as size_t, mask as long )

	dim as size_t avail, avail_len
	dim temp as ubyte ptr

	if( __fb_con.inited = 0 ) then
	
		/' !!!FIXME!!! is this ok or should it be converted to UTF-8 too? '/
		fwrite( cast(FB_WCHAR ptr, buffer), sizeof( FB_WCHAR ), chars, stdout )
		fflush( stdout )
		Exit Sub
	end if

	temp = Allocate( chars * 4 + 1 )

	BG_LOCK( )
	fb_hRecheckConsoleSize( TRUE )
	BG_UNLOCK( )

	/' ToDo: handle scrolling for internal characters/attributes buffer? '/
	avail = (__fb_con.w * __fb_con.h) - (((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1)
	avail_len = chars
	if (avail < avail_len) then
		avail_len = avail
	end if

	/' !!!FIXME!!! to support unicode the char_buffer would have to be a wchar_t,
				   slowing down non-unicode printing.. '/
	fb_wstr_ConvToA( temp, avail_len, buffer )

	memcpy( __fb_con.char_buffer + ((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1, _
	        temp, _
	        avail_len )

	memset( __fb_con.attr_buffer + ((__fb_con.cur_y - 1) * __fb_con.w) + __fb_con.cur_x - 1, _
	        __fb_con.fg_color Or (__fb_con.bg_color Shl 4), _
	        avail_len )

	/' convert wchar_t to UTF-8 '/
	dim bytes as ssize_t

	fb_WCharToUTF( FB_FILE_ENCOD_UTF8, buffer, chars, temp, @bytes )
	/' add null-term '/
	temp[bytes] = 0

	fputs( ENTER_UTF8, stdout )

	fputs( temp, stdout )

	fputs( EXIT_UTF8, stdout )

	/' update x and y coordinates.. '/
	While chars <> 0
	
		__fb_con.cur_x += 1
		if( (*buffer = asc(!"\n")) OrElse (__fb_con.cur_x >= __fb_con.w) ) then
		
			__fb_con.cur_x = 1
			__fb_con.cur_y += 1
			if( __fb_con.cur_y > __fb_con.h ) then
				__fb_con.cur_y = __fb_con.h
			end if
		end if
		chars -= 1
		buffer += 1
	Wend

	fflush( stdout )
End Sub

Sub fb_ConsolePrintBufferWstr( buffer as const FB_WCHAR ptr, mask as long )

	fb_ConsolePrintBufferWstrEx( buffer, fb_wstr_Len( buffer ), mask )
End Sub
End Extern
