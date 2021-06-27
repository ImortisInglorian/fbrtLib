/' comfortable INPUT function '/

#include "fb.bi"

extern "C"
private sub DoAdjust( x as long ptr, y as long ptr, dx as long, dy as long, cols as long , rows as long )
    DBG_ASSERT( x <> NULL and y <> NULL )

    *x -= 1
    *y -= 1

    *x += dx
    if ( *x < 0 ) then
        *x = -*x + cols
        *y -= *x / cols
        *x = cols - (*x mod cols)
    end if
    *y += *x / cols
    *x mod= cols
    *y += dy

    *x += 1
    *y += 1
end sub

private sub DoMove( x as long ptr, y as long ptr, dx as long, dy as long, cols as long, rows as long )
    DoAdjust( x, y, dx, dy, cols, rows )
    if ( *y = (rows+1) and *x = 1 ) then
        fb_Locate( rows, cols, -1, 0, 0 )
        fb_PrintBufferEx( cast(any const ptr, @FB_NEWLINE), sizeof(FB_NEWLINE)-1, 0 )
    else
        fb_Locate( *y, *x, -1, 0, 0 )
    end if
end sub

function fb_ConReadLine FBCALL ( soft_cursor as long ) as FBSTRING ptr
	dim as FBSTRING result = ( 0, 0, 0 )

    dim as long current_x, current_y
    dim as long cols, rows
    dim as size_t _pos, _len, tmp_buffer_len = 0
    dim as long cursor_visible
    dim as long k
    dim as ubyte tmp_buffer(0 to 11)

    fb_GetSize(@cols, @rows)

    cursor_visible = (fb_Locate( 0, 0, -1, 0, 0 ) and &h10000) <> 0
    fb_Locate( 0, 0, FALSE, 0, 0 )

    _pos = 0
	_len = 0
    fb_PrintBufferEx( NULL, 0, 0 )

    /' Ensure that the cursor is visible during INPUT '/
    fb_Locate( 0, 0, (soft_cursor = FALSE), 0, 0 )

	do
		dim as size_t delete_char_count = 0, add_char = FALSE
		dim as FBSTRING ptr s

		fb_GetXY( @current_x, @current_y )

		if ( soft_cursor <> NULL ) then
			fb_PrintFixString( 0, sadd("\377"), 0 )
			fb_Locate( current_y, current_x, FALSE, 0, 0 )
		end if

		while( fb_KeyHit( ) = 0 )
			fb_Delay( 25 )				/' release time slice '/
		wend

		s = fb_Inkey( )
		if ( s->data <> NULL ) then
			if ( FB_STRSIZE( s ) = 2 ) then
				k = FB_MAKE_EXT_KEY( FB_CHAR_TO_INT( s->data[1] ) )
			else
				k = FB_CHAR_TO_INT( s->data[0] )
			end if

			fb_hStrDelTemp( s )
		else
			k = 0
			continue do
		end if

		if ( soft_cursor <> 0 ) then
			dim as ubyte mask(0 to 1) = { iif((result.data <> NULL) and (_pos < _len), result.data[_pos], asc(" ")), 0 }
			fb_PrintFixString( 0, cast(ubyte const ptr, @mask(0)), 0 )
			fb_Locate( current_y, current_x, FALSE, 0, 0 )
		end if

		select case( k )
			case 8:  /' Backspace '/
				if ( _pos <> 0 ) then
					DoMove( @current_x, @current_y, -1, 0, cols, rows )
					_pos -= 1
					delete_char_count = 1
				end if

			case 9:  /' TAB '/
				tmp_buffer_len = ((_pos + 8) / 8 * 8) - _pos
				memset( @tmp_buffer(0), 32, tmp_buffer_len )
				add_char = TRUE

			case 27:  /' ESC '/
				DoMove( @current_x, @current_y, -pos, 0, cols, rows )
				_pos = 0
				delete_char_count = _len

			case KEY_DEL:  /' Delete following char '/
				/' not at EOL already? '/
				if ( _len <> _pos ) then
					delete_char_count = 1
				else
					fb_Beep()
				end if

			case KEY_LEFT:  /' Move cursor left '/
				/' not at begin-of-line already? '/
				if ( _pos <> 0 ) then
					DoMove( @current_x, @current_y, -1, 0, cols, rows )
					_pos -= 1
				end if

			case KEY_RIGHT: /' Move cursor right '/
				/' not at EOL already? '/
				if ( _pos <> _len ) then
					DoMove( @current_x, @current_y, 1, 0, cols, rows )
					_pos += 1
				end if

			case KEY_HOME:  /' Move cursor to begin-of-line '/
				DoMove( @current_x, @current_y, -_pos, 0, cols, rows )
				_pos = 0

			case KEY_END:  /' Move cursor to EOL '/
				DoMove( @current_x, @current_y, _len-_pos, 0, cols, rows )
				_pos = _len

			case KEY_UP:  /' Move cursor up '/
				if ( _pos >= cast(size_t, cols) ) then
					DoMove( @current_x, @current_y, -cols, 0, cols, rows )
					_pos -= cols
				end if

			case KEY_DOWN:  /' Move cursor down '/
				if ( (_pos + cols) <= _len ) then
					DoMove( @current_x, @current_y, cols, 0, cols, rows )
					_pos += cols
				end if

			case else:
				if ( (k >= 32) and (k <= 255) ) then
					tmp_buffer(0) = cast(ubyte, k)
					tmp_buffer_len = 1
					add_char = TRUE
					/' DoMove( &current_x, &current_y, 1, 0, cols ); '/
				end if
		end select

		if ( (delete_char_count <> 0) or add_char <> 0 ) then
			/' Turn off the cursor during output (speed-up) '/
			fb_Locate( 0, 0, FALSE, 0, 0 )
		end if

        if ( delete_char_count <> 0 ) then
            dim as FBSTRING ptr str_fill
            dim as FBSTRING ptr str_left = fb_StrMid( @result, 1, _pos )
            dim as FBSTRING ptr str_right = fb_StrMid( @result, _pos + 1 + delete_char_count, _len - _pos - delete_char_count)
            fb_StrAssign( @result, -1, str_left, -1, FALSE )
            fb_StrConcatAssign( @result, -1, str_right, -1, FALSE )
            _len -= delete_char_count

            FB_LOCK()

            fb_PrintBufferEx( result.data + _pos, _len - _pos, 0 )

            /' Overwrite all deleted characters with SPC's '/
            str_fill = fb_StrFill1 ( delete_char_count, 32 )
            fb_PrintBufferEx( str_fill->data, delete_char_count, 0 )
            fb_hStrDelTemp( str_fill )

            fb_Locate( current_y, current_x, -1, 0, 0 )

            FB_UNLOCK()
        end if

        if ( add_char <> 0 ) then
            tmp_buffer(tmp_buffer_len) = 0
        end if

        if ( add_char <> 0 ) then
            dim as long old_x = current_x, old_y = current_y
            dim as FBSTRING ptr str_add = fb_StrAllocTempDescF( cast(ubyte ptr, @tmp_buffer(0)), tmp_buffer_len + 1 )
            dim as FBSTRING ptr str_left = fb_StrMid( @result, 1, _pos )
            dim as FBSTRING ptr str_right = fb_StrMid( @result, _pos + 1, _len - _pos)
            fb_StrAssign( @result, -1, str_left, -1, FALSE )
            fb_StrConcatAssign( @result, -1, str_add, -1, FALSE )
            fb_StrConcatAssign( @result, -1, str_right, -1, FALSE )
            _len += tmp_buffer_len

            FB_LOCK()

            fb_PrintBufferEx( result.data + _pos, _len - _pos, 0 )

            fb_GetXY(@current_x, @current_y)

            if ( _pos = (_len-tmp_buffer_len) ) then
                current_x = old_x
				current_y = old_y
                DoMove( @current_x, @current_y, tmp_buffer_len, 0, cols, rows )
            else
                dim as long tmp_x_2 = old_x, tmp_y_2 = old_y
                DoAdjust( @tmp_x_2, @tmp_y_2, _len - _pos, 0, cols, rows )
                if ( tmp_y_2 > (rows + 1) or (tmp_y_2 = (rows + 1) and tmp_x_2 > 1) ) then
                    DoMove( @current_x, @current_y, -(_len - _pos - tmp_buffer_len), 0, cols, rows )
                else
                    current_x = old_x
					current_y = old_y
                    DoMove( @current_x, @current_y, tmp_buffer_len, 0, cols, rows )
                end if
            end if
            _pos += tmp_buffer_len

            FB_UNLOCK()
        end if

        fb_Locate( 0, 0, (soft_cursor = FALSE), 0, 0 )

	loop while (k <> ASC(!"\n") and k <> ASC(!"\r"))

    FB_LOCK()

    /' set cursor to end of line '/
    fb_GetXY(@current_x, @current_y)
    DoMove( @current_x, @current_y, _len - _pos, 0, cols, rows )

    /' Restore old cursor visibility '/
    fb_Locate( 0, 0, cursor_visible, 0, 0 )

    FB_UNLOCK()

	return fb_StrAllocTempResult( @result )
end function
end extern
