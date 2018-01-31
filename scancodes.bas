#include "fb.bi"

extern "C"
function  fb_hScancodeToExtendedKey( scancode as long ) as long
	dim as long key

	/' FB scancode to FB key translation,
	   currently only used for extended keys. '/
	select case( scancode )
		case SC_F1:
			key = KEY_F1
		case SC_F2:
			key = KEY_F2
		case SC_F3:
			key = KEY_F3
		case SC_F4:
			key = KEY_F4
		case SC_F5:
			key = KEY_F5
		case SC_F6:
			key = KEY_F6
		case SC_F7:
			key = KEY_F7
		case SC_F8:
			key = KEY_F8
		case SC_F9:
			key = KEY_F9
		case SC_F10:
			key = KEY_F10
		case SC_HOME:
			key = KEY_HOME
		case SC_UP:
			key = KEY_UP
		case SC_PAGEUP:
			key = KEY_PAGE_UP
		case SC_LEFT:
			key = KEY_LEFT
		case SC_CLEAR:
			key = KEY_CLEAR
		case SC_RIGHT:
			key = KEY_RIGHT
		case SC_END:
			key = KEY_END
		case SC_DOWN:
			key = KEY_DOWN
		case SC_PAGEDOWN:
			key = KEY_PAGE_DOWN
		case SC_INSERT:
			key = KEY_INS
		case SC_DELETE:
			key = KEY_DEL
		case else:
			key = 0
	end select

	return key
end function
end extern