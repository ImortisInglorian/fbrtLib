/' console input helpers '/

#ifdef fb_hConsolePostKey
	#undef fb_hConsolePostKey
#endif

#include "../fb.bi"
#include "fb_private_console.bi"
#include "crt/ctype.bi"

#define KEY_BUFFER_LEN 512

dim shared as long key_buffer(0 to KEY_BUFFER_LEN - 1)
dim shared as size_t key_head = 0, key_tail = 0
dim shared as INPUT_RECORD input_events(0 to KEY_BUFFER_LEN - 1)
dim shared as ulong key_scratch_pad = 0
dim shared as long key_buffer_changed = FALSE

type FB_KEY_CODES
    as ushort value_normal
    as ushort value_shift
    as ushort value_ctrl
    as ushort value_alt
end type

type FB_KEY_LIST_ENTRY
    as ushort scan_code
    as FB_KEY_CODES codes
end type

dim shared as const FB_KEY_LIST_ENTRY fb_ext_key_entries(0 to 11) = { _
    ( &h001C, ( &h000D, &h000D, &h000A, &hA600 ) ), _
    ( &h0035, ( &h002F, &h003F, &h9500, &hA400 ) ), _
    ( &h0047, ( &h4700, &h4700, &h7700, &h9700 ) ), _
    ( &h0048, ( &h4800, &h4800, &h8D00, &h9800 ) ), _
    ( &h0049, ( &h4900, &h4900, &h8400, &h9900 ) ), _
    ( &h004B, ( &h4B00, &h4B00, &h7300, &h9B00 ) ), _
    ( &h004D, ( &h4D00, &h4D00, &h7400, &h9D00 ) ), _
    ( &h004F, ( &h4F00, &h4F00, &h7500, &h9F00 ) ), _
    ( &h0050, ( &h5000, &h5000, &h9100, &hA000 ) ), _
    ( &h0051, ( &h5100, &h5100, &h7600, &hA100 ) ), _
    ( &h0052, ( &h5200, &h5200, &h9200, &hA200 ) ), _
    ( &h0053, ( &h5300, &h5300, &h9300, &hA300 ) ) _
}

#define FB_KEY_LIST_SIZE (sizeof(fb_ext_key_entries)/sizeof(FB_KEY_LIST_ENTRY))

dim shared as const FB_KEY_CODES fb_asc_key_codes(0 to 88) => { _
    type( &h0000, &h0000, &h0000, &h0000 ), _
    type( &h001B, &h001B, &h001B, &h0100 ), _
    type( &h0031, &h0021, &h0000, &h7800 ), _
    type( &h0032, &h0040, &h0300, &h7900 ), _
    type( &h0033, &h0023, &h0000, &h7A00 ), _
    type( &h0034, &h0024, &h0000, &h7B00 ), _
    type( &h0035, &h0025, &h0000, &h7C00 ), _
    type( &h0036, &h005E, &h001E, &h7D00 ), _
    type( &h0037, &h0026, &h001F, &h7E00 ), _
    type( &h0038, &h002B, &h0000, &h7F00 ), _
    type( &h0039, &h0028, &h0000, &h8000 ), _
    type( &h0030, &h0029, &h0000, &h8100 ), _
    type( &h002D, &h005F, &h001F, &h8200 ), _
    type( &h003D, &h002B, &h0000, &h8300 ), _
    type( &h0008, &h0008, &h007F, &hE000 ), _
    type( &h0009, &h0F00, &h9400, &h0F00 ), _
    type( &h0071, &h0051, &h0011, &h1000 ), _ /' 16 '/
    type( &h0077, &h0057, &h0017, &h1100 ), _
    type( &h0065, &h0045, &h0005, &h1200 ), _
    type( &h0072, &h0052, &h0012, &h1300 ), _
    type( &h0074, &h0054, &h0014, &h1400 ), _
    type( &h0079, &h0059, &h0019, &h1500 ), _
    type( &h0075, &h0055, &h0015, &h1600 ), _
    type( &h0069, &h0049, &h0009, &h1700 ), _
    type( &h006F, &h004F, &h000F, &h1800 ), _
	type( &h0070, &h0050, &h0010, &h1900 ), _
	type( &h005B, &h007B, &h001B, &h1A00 ), _
	type( &h005D, &h007D, &h001D, &h1B00 ), _
    type( &h000D, &h000D, &h000A, &h1C00 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h0061, &h0041, &h0001, &h1E00 ), _
	type( &h0073, &h0053, &h0013, &h1F00 ), _
    type( &h0064, &h0044, &h0004, &h2000 ), _ /' 32 '/
	type( &h0066, &h0046, &h0006, &h2100 ), _
	type( &h0067, &h0047, &h0007, &h2200 ), _
	type( &h0068, &h0048, &h0008, &h2300 ), _
    type( &h006A, &h004A, &h000A, &h2400 ), _
	type( &h006B, &h004B, &h000B, &h2500 ), _
	type( &h006C, &h004C, &h000C, &h2600 ), _
	type( &h003B, &h003A, &h0000, &h2700 ), _
    type( &h0027, &h0022, &h0000, &h2800 ), _
	type( &h0060, &h007E, &h0000, &h2900 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h005C, &h007C, &h001C, &h0000 ), _
    type( &h007A, &h005A, &h001A, &h2C00 ), _
	type( &h0078, &h0058, &h0018, &h2D00 ), _
	type( &h0063, &h0043, &h0003, &h2E00 ), _
	type( &h0076, &h0056, &h0016, &h2F00 ), _
    type( &h0062, &h0042, &h0002, &h3000 ), _ /' 48 '/
	type( &h006E, &h004E, &h000E, &h3100 ), _
	type( &h006D, &h004D, &h000D, &h3200 ), _
	type( &h002C, &h003C, &h0000, &h3300 ), _
    type( &h002E, &h003E, &h0000, &h3400 ), _
	type( &h002F, &h003F, &h0000, &h3500 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h002A, &h0000, &h0072, &h0000 ), _
    type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h0020, &h0020, &h0020, &h0020 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h3B00, &h5400, &h5E00, &h6800 ), _
    type( &h3C00, &h5500, &h5F00, &h6900 ), _
	type( &h3D00, &h5600, &h6000, &h6A00 ), _
	type( &h3E00, &h5700, &h6100, &h6B00 ), _
	type( &h3F00, &h5800, &h6200, &h6C00 ), _
    type( &h4000, &h5900, &h6300, &h6D00 ), _ /' 64 '/
	type( &h4100, &h5A00, &h6400, &h6E00 ), _
	type( &h4200, &h5B00, &h6500, &h6F00 ), _
	type( &h4300, &h5C00, &h6600, &h7000 ), _
    type( &h4400, &h5D00, &h6700, &h7100 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h4700, &h0037, &h7700, &h0000 ), _
    type( &h4800, &h0038, &h8D00, &h0000 ), _
	type( &h4900, &h0039, &h8400, &h0000 ), _
	type( &h0000, &h002D, &h0000, &h0000 ), _
	type( &h4B00, &h0034, &h7300, &h0000 ), _
    type( &h4C00, &h0035, &h8F00, &h4C00 ), _
	type( &h4D00, &h0036, &h7400, &h0000 ), _
	type( &h0000, &h002B, &h0000, &h0000 ), _
	type( &h4F00, &h0031, &h7500, &h0000 ), _
    type( &h5000, &h0032, &h9100, &h0000 ), _ /' 80 '/
	type( &h5100, &h0033, &h7600, &h0000 ), _
	type( &h5200, &h0030, &h9200, &h0000 ), _
	type( &h5300, &h002E, &h9300, &h0000 ), _
    type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h0000, &h0000, &h0000, &h0000 ), _
	type( &h8500, &h8700, &h8900, &h8B00 ), _
    type( &h8600, &h8800, &h8A00, &h8C00 ) _
}

#define FB_KEY_CODES_SIZE (sizeof(fb_asc_key_codes)/sizeof(FB_KEY_CODES))

dim shared as long control_handler_inited = FALSE

extern "C"
private sub fb_hConsolePostKey ( key as long, _key_event as KEY_EVENT_RECORD const ptr )
    dim as INPUT_RECORD ptr record

    FB_LOCK()

    key_buffer(key_tail) = key

    DBG_ASSERT( _key_event <> NULL )

    record = @input_events(0) + key_tail
    memcpy( @record->Event.KeyEvent, _key_event, sizeof( KEY_EVENT_RECORD ) )
    record->EventType = KEY_EVENT

	if (((key_tail + 1) and (KEY_BUFFER_LEN - 1)) = key_head) then
		key_head = (key_head + 1) and (KEY_BUFFER_LEN - 1)
	end if
    key_tail = (key_tail + 1) and (KEY_BUFFER_LEN - 1)

    key_buffer_changed = TRUE

    FB_UNLOCK()
end sub

function fb_hConsoleInputBufferChanged( ) as long
    dim as long result

    fb_ConsoleProcessEvents( )

    FB_LOCK()
    result = key_buffer_changed
    key_buffer_changed = FALSE
    FB_UNLOCK()

    return result
end function

private function fb_hConsoleGetKeyEx( full as long, allow_remove as long ) as long
    dim as long key = -1

    fb_ConsoleProcessEvents( )

	FB_LOCK()

    if (key_head <> key_tail) then
        dim as long do_remove = allow_remove
        key = key_buffer(key_head)
        if ( key > 255 ) then
            if ( not(full) ) then
                key_buffer(key_head) = (key shr 8)
                key = cast(long, cast(ubyte, FB_EXT_CHAR))
                do_remove = FALSE
            end if
        end if
        if ( do_remove ) then
            key_head = (key_head + 1) and (KEY_BUFFER_LEN - 1)
            /' Reset the status for "key buffer changed" when a key
             * was removed from the input queue. '/
            fb_hConsoleInputBufferChanged()
        end if
	end if

	FB_UNLOCK()

	return key
end function

function fb_hConsoleGetKey( full as long ) as long
    return fb_hConsoleGetKeyEx( full, TRUE )
end function

function fb_hConsolePeekKey( full as long ) as long
    return fb_hConsoleGetKeyEx( full, FALSE )
end function

sub fb_hConsolePutBackEvents( )
    dim as size_t key_idx

    FB_LOCK()

    while( fb_ConsoleProcessEvents( ) )
		'
	wend

    key_idx = key_head
    while( key_idx <> key_tail )
        dim as DWORD dwEventsWritten = 0
        dim as size_t count = iif((key_idx > key_tail), (KEY_BUFFER_LEN - key_idx), (key_tail - key_idx))

        WriteConsoleInput( __fb_in_handle, @input_events(0) + key_idx, count, @dwEventsWritten )

        key_idx += count
        if ( key_idx = KEY_BUFFER_LEN ) then
            key_idx = 0
		end if
	wend

    FB_UNLOCK()
end sub

private sub fb_hConsoleProcessKeyEvent( event as KEY_EVENT_RECORD const ptr )
    dim as long KeyCode
    dim as long ValidKeyStatus, ValidKeys, AddScratchPadKey = FALSE
    if ( event->bKeyDown ) then
        KeyCode = fb_hConsoleTranslateKey( event->uChar.AsciiChar, event->wVirtualScanCode, event->wVirtualKeyCode, event->dwControlKeyState, FALSE )
    else
        KeyCode = -1
    end if

    ValidKeyStatus = ((event->dwControlKeyState and (LEFT_CTRL_PRESSED or RIGHT_CTRL_PRESSED or SHIFT_PRESSED)) = 0) and ((event->dwControlKeyState and (LEFT_ALT_PRESSED or RIGHT_ALT_PRESSED)) <> 0)
#if 0
    ValidKeys = (event->wVirtualScanCode >= &h47 and event->wVirtualScanCode <= &h49) or (event->wVirtualScanCode >= &h4b and event->wVirtualScanCode <= &h4d) or (event->wVirtualScanCode >= &h4f and event->wVirtualScanCode <= &h52);
#else
    ValidKeys = (event->wVirtualKeyCode >= VK_NUMPAD0 and event->wVirtualKeyCode <= VK_NUMPAD9)
#endif

    if ( ValidKeys and ValidKeyStatus ) then
        if ( event->bKeyDown ) then
            dim as long number
#if 0
            if( event->wVirtualScanCode <= &h49 ) then
                number = event->wVirtualScanCode - &h40
            elseif ( event->wVirtualScanCode <= &h4d ) then
                number = event->wVirtualScanCode - &h47
            elseif ( event->wVirtualScanCode <= &h51 ) then
                number = event->wVirtualScanCode - &h4e
            else
                number = 0
            end if
#else
            number = event->wVirtualKeyCode - VK_NUMPAD0
#endif
            key_scratch_pad *= 10
            key_scratch_pad += number
        end if
    elseif ( KeyCode <> -1 ) then
        key_scratch_pad = 0
    elseif ( not(ValidKeyStatus) ) then
        AddScratchPadKey = key_scratch_pad <> 0
    end if

#if 0
    printf("%04hx\n", event->wVirtualScanCode)
    printf("%04hx, %08x\n", event->wVirtualKeyCode, MapVirtualKey( event->wVirtualScanCode, 1))
    printf("%02x\n", cast(ulong, cast(ubyte, event->uChar.AsciiChar)))
    printf("%08x, %d\n", key_scratch_pad, ValidKeyStatus)
#endif

    if ( AddScratchPadKey ) then
        dim as ubyte chAsciiCode= cast(char, (key_scratch_pad and &hFF))
        dim as KEY_EVENT_RECORD rec
        dim as SHORT wVkCode = VkKeyScan(chAsciiCode)
        memset( @rec, 0, sizeof(KEY_EVENT_RECORD) )
        rec.uChar.AsciiChar = chAsciiCode
        rec.wVirtualKeyCode = wVkCode and &hFF
        rec.dwControlKeyState or= iif(((wVkCode and &h100) <> 0), SHIFT_PRESSED, 0)
        rec.dwControlKeyState or= iif(((wVkCode and &h200) <> 0), LEFT_CTRL_PRESSED, 0)
        rec.dwControlKeyState or= iif(((wVkCode and &h400) <> 0), LEFT_ALT_PRESSED, 0)
        rec.wVirtualScanCode = MapVirtualKey( rec.wVirtualKeyCode, 0 )
        fb_hConsolePostKey( key_scratch_pad and &hFF, @rec )
        key_scratch_pad = 0
    end if

    if ( KeyCode <> -1 ) then
        fb_hConsolePostKey(KeyCode, event)
    end if
end sub

private function fb_hConsoleHandlerRoutine ( dwCtrlType as DWORD  ) as BOOL
    select case dwCtrlType
		case CTRL_CLOSE_EVENT, CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT:
            dim as KEY_EVENT_RECORD rec
            memset( @rec, 0, sizeof(KEY_EVENT_RECORD) )
            rec.wVirtualKeyCode = VK_F4
            rec.dwControlKeyState = LEFT_ALT_PRESSED
            rec.wVirtualScanCode = MapVirtualKey( rec.wVirtualKeyCode, 0 )
            fb_hConsolePostKey( KEY_QUIT, @rec )
       
			return TRUE
    end select
    return FALSE
end function

private sub fb_hExitControlHandler( )
    if ( control_handler_inited ) then
        SetConsoleCtrlHandler( fb_hConsoleHandlerRoutine, FALSE )
    end if
end sub

private sub fb_hInitControlHandler( )
    FB_LOCK()
    if( not(control_handler_inited) ) then
        control_handler_inited = TRUE
        atexit( fb_hExitControlHandler )
        SetConsoleCtrlHandler( fb_hConsoleHandlerRoutine, TRUE )
    end if
    FB_UNLOCK()
end sub

function fb_ConsoleProcessEvents( ) as long
    dim as long got_event = FALSE
	dim as INPUT_RECORD ir
    dim as DWORD dwRead

    fb_hInitControlHandler()

    do
        if ( not(PeekConsoleInput( __fb_in_handle, @ir, 1, @dwRead ) ) ) then
            dwRead = 0
		end if

        if ( dwRead > 0 ) then
            ReadConsoleInput( __fb_in_handle, @ir, 1, @dwRead )

            FB_LOCK()

            select case ir.EventType
				case KEY_EVENT:
					if ( ir.Event.KeyEvent.bKeyDown and ir.Event.KeyEvent.wRepeatCount <> 0 ) then
						dim as size_t i
						for i = 0 to ir.Event.KeyEvent.wRepeatCount
							fb_hConsoleProcessKeyEvent( @ir.Event.KeyEvent )
						next
					elseif ( not(ir.Event.KeyEvent.bKeyDown) ) then
						fb_hConsoleProcessKeyEvent( @ir.Event.KeyEvent )
					end if

				case MOUSE_EVENT:
					if ( __fb_con.mouseEventHook <> cast(fb_FnProcessMouseEvent, NULL) ) then
						__fb_con.mouseEventHook( @ir.Event.MouseEvent )
						got_event = TRUE
					end if
            end select

            FB_UNLOCK()
        end if

    loop while( dwRead <> 0 )

	return got_event
end function

/'  Translates an ASCII character, Virtual scan code and Virtual key code to
 *  a single QB-compatible keyboard code.
 *
 * @returns -1 if key not translatable
 '/
function fb_hConsoleTranslateKey ( AsciiChar as ubyte, wVsCode as WORD, wVkCode as WORD, dwControlKeyState as DWORD, bEnhancedKeysOnly as long ) as long
    dim as long KeyCode = 0, AddKeyCode = FALSE
    dim as long is_ext_code = AsciiChar = 0

    /' Process ENHANCED_KEY's in a different way '/
    if ( (dwControlKeyState and ENHANCED_KEY) <> 0 and is_ext_code) then
        dim as size_t i
        for i = 0 to FB_KEY_LIST_SIZE - 1
            const as FB_KEY_LIST_ENTRY ptr entry = fb_ext_key_entries + i
            if (entry->scan_code = wVsCode) then
                const as  FB_KEY_CODES ptr codes = @entry->codes
                if ( dwControlKeyState and (LEFT_ALT_PRESSED or RIGHT_ALT_PRESSED) ) then
                    KeyCode = codes->value_alt
                    AddKeyCode = KeyCode <> 0
                elseif ( dwControlKeyState and (LEFT_CTRL_PRESSED or RIGHT_CTRL_PRESSED) ) then
                    KeyCode = codes->value_ctrl
                    AddKeyCode = KeyCode <> 0
                elseif ( dwControlKeyState and SHIFT_PRESSED ) then
                    KeyCode = codes->value_shift
                    AddKeyCode = KeyCode <> 0
                else
                    KeyCode = codes->value_normal
                    AddKeyCode = TRUE
                end if
                exit for
            end if
        next
    else
        dim as ulong uiAsciiChar = cast(ulong, cast(ubyte, AsciiChar))
        dim as ulong uiNormalKey, uiNormalKeyOtherCase
        /' Test if we must translate a "normal" key into an enhanced key '/
        if ( wVsCode < FB_KEY_CODES_SIZE ) then
            const as FB_KEY_CODES ptr codes = fb_asc_key_codes + wVsCode

            uiNormalKey = MapVirtualKey( wVkCode, 2 ) and &hFFFF
            if ( isupper( cast(long, uiNormalKey) ) ) then
                uiNormalKeyOtherCase = tolower( cast(long, uiNormalKey) )
            elseif ( islower( cast(long, uiNormalKey) ) ) then
                uiNormalKeyOtherCase = toupper( cast(long, uiNormalKey) )
            else
                uiNormalKeyOtherCase = uiNormalKey
            end if

            if ( dwControlKeyState and (LEFT_ALT_PRESSED or RIGHT_ALT_PRESSED) ) then
                KeyCode = codes->value_alt
            elseif ( dwControlKeyState and (LEFT_CTRL_PRESSED or RIGHT_CTRL_PRESSED) ) then
                KeyCode = codes->value_ctrl
            elseif ( dwControlKeyState and SHIFT_PRESSED ) then
                KeyCode = codes->value_shift
            else
                if ( uiAsciiChar = 0 ) then
                    KeyCode = codes->value_normal
                else
                    KeyCode = uiNormalKey
                end if
            end if
            /' Add the found key code only when the following conditions are
             * met:
             * 1. KeyCode must be > 255 (enhanced)
             * 2. The ASCII character provided must be different from the
             *    "normal" character - this test is required to allow
             *    AltGr+character combinations that are language-specific
             *    and therefore quite hard to detect ... '/
            AddKeyCode = (KeyCode > 255) and ((uiAsciiChar = uiNormalKey) or (uiAsciiChar = uiNormalKeyOtherCase))
        end if

        if ( not(AddKeyCode) and not(bEnhancedKeysOnly)) then
            if ( not(is_ext_code) ) then
                /' The key code is simply the returned ASCII character '/
                KeyCode = uiAsciiChar
                AddKeyCode = TRUE
            end if
        end if
    end if

    if ( AddKeyCode ) then
        if ( KeyCode > 255 ) then
            KeyCode = FB_MAKE_EXT_KEY(cast(char, (KeyCode shr 8)))
		end if
        return KeyCode
    wnd if
    return -1
end function
end extern