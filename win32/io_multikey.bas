/' multikey function for Windows console mode apps '/

#include "../fb.bi"
#include "windows.bi"

dim shared as ubyte __fb_keytable(0 to 86, 0 to 2) = { _
	{ SC_ESCAPE,	VK_ESCAPE,	0			},	{ SC_1,			 49,		0			}, _
	{ SC_2,			 50,		0			},	{ SC_3,			 51,		0			}, _
	{ SC_4,			 52,		0			},	{ SC_5,			 53,		0			}, _
	{ SC_6,			 54,		0			},	{ SC_7,			 55,		0			}, _
	{ SC_8,			 56,		0			},	{ SC_9,			 57,		0			}, _
	{ SC_0,			 48,		0			},	{ SC_MINUS,		&hBD,		VK_SUBTRACT	}, _
	{ SC_EQUALS,	&hBB,		0			},	{ SC_BACKSPACE,	VK_BACK,	0			}, _
	{ SC_TAB,		VK_TAB,		0			},	{ SC_Q,			 81,		0			}, _
	{ SC_W,			 87,		0			},	{ SC_E, 		 69,		0			}, _
	{ SC_R,			 82,		0			},	{ SC_T,			 84,		0			}, _
	{ SC_Y,			 89,		0			},	{ SC_U,			 85,		0			}, _
	{ SC_I,			 73,		0			},	{ SC_O,			 79,		0			}, _
	{ SC_P,			 80,		0			},	{ SC_LEFTBRACKET,&hDB,		0			}, _
	{ SC_RIGHTBRACKET,&hDD,		0			},	{ SC_ENTER,		VK_RETURN,	0			}, _
	{ SC_CONTROL, 	VK_CONTROL,	0			},	{ SC_A,			 65,		0			}, _
	{ SC_S,			 83,		0			},	{ SC_D,			 68,		0			}, _
	{ SC_F,			 70,		0			},	{ SC_G,			 71,		0			}, _
	{ SC_H,			 72,		0			},	{ SC_J,			 74,		0			}, _
	{ SC_K,			 75,		0			},	{ SC_L,			 76,		0			}, _
	{ SC_SEMICOLON,	&hBA,		0			},	{ SC_QUOTE,		&hDE,		0			}, _
	{ SC_TILDE,		&hC0,		0			},	{ SC_LSHIFT,	VK_SHIFT,	0			}, _
	{ SC_BACKSLASH,	&hDC,		0			},	{ SC_Z,			 90,		0			}, _
	{ SC_X,			 88,		0			},	{ SC_C,			 67,		0			}, _
	{ SC_V,			 86,		0			},	{ SC_B,			 66,		0			}, _
	{ SC_N,			 78,		0			},	{ SC_M,			 77,		0			}, _
	{ SC_COMMA,		&hBC,		0			},	{ SC_PERIOD,	&hBE,		0			}, _
	{ SC_SLASH,		&hBF,		VK_DIVIDE	},	{ SC_RSHIFT,	VK_SHIFT,	0			}, _
	{ SC_MULTIPLY,	VK_MULTIPLY,0			},	{ SC_ALT,		VK_MENU,	0			}, _
	{ SC_SPACE,		VK_SPACE,	0			},	{ SC_CAPSLOCK,	VK_CAPITAL,	0			}, _
	{ SC_F1,		VK_F1,		0			},	{ SC_F2,		VK_F2,		0			}, _
	{ SC_F3,		VK_F3,		0			},	{ SC_F4,		VK_F4,		0			}, _
	{ SC_F5,		VK_F5,		0			},	{ SC_F6,		VK_F6,		0			}, _
	{ SC_F7,		VK_F7,		0			},	{ SC_F8,		VK_F8,		0			}, _
	{ SC_F9,		VK_F9,		0			},	{ SC_F10,		VK_F10,		0			}, _
	{ SC_NUMLOCK,	VK_NUMLOCK,	0			},	{ SC_SCROLLLOCK,VK_SCROLL,	0			}, _
	{ SC_HOME,		VK_HOME,	VK_NUMPAD7	},	{ SC_UP,		VK_UP,		VK_NUMPAD8	}, _
	{ SC_PAGEUP,	VK_PRIOR,	VK_NUMPAD9	},	{ SC_LEFT,		VK_LEFT,	VK_NUMPAD4	}, _
	{ SC_RIGHT,		VK_RIGHT,	VK_NUMPAD6	},	{ SC_PLUS,		VK_ADD,		0			}, _
	{ SC_END,		VK_END,		VK_NUMPAD1	},	{ SC_DOWN,		VK_DOWN,	VK_NUMPAD2	}, _
	{ SC_PAGEDOWN,	VK_NEXT,	VK_NUMPAD3	},	{ SC_INSERT,	VK_INSERT,	VK_NUMPAD0	}, _
	{ SC_DELETE,	VK_DELETE,	VK_DECIMAL	},	{ SC_F11,		VK_F11,		0			}, _
	{ SC_F12,		VK_F12,		0			},	{ SC_LWIN,		VK_LWIN,	0			}, _
	{ SC_RWIN,		VK_RWIN,	0			},	{ SC_MENU,		VK_APPS,	0			}, _
	{ 0,			0,			0			} _
}

extern "C"
private function find_window() as HWND
	dim as TCHAR old_title(0 to MAX_PATH - 1)
	dim as TCHAR title(0 to MAX_PATH - 1)
	static as HWND _hwnd = NULL

	if ( _hwnd <> NULL ) then
		return _hwnd
	end if

	if ( GetConsoleTitle(@old_title(0), MAX_PATH) <> NULL ) then
		sprintf(@title(0), "_fb_console_title %f", fb_Timer())
		SetConsoleTitle(@title(0))
		_hwnd = FindWindow(NULL, @title(0))
		SetConsoleTitle(@old_title(0))
	end if
	return _hwnd
end function

function fb_hVirtualToScancode(vkey as long ) as long
	dim as long i
	
	do 
		if ((__fb_keytable(i, 2) = vkey) or (__fb_keytable(i, 1) = vkey)) then
			return __fb_keytable(i, 0)
		end if
		i += 1
	loop while (__fb_keytable(i,0))
	return 0
end function

function fb_ConsoleMultikey( scancode as long ) as long
	dim as long i

	if ( find_window() <> GetForegroundWindow() ) then
		return FB_FALSE
	end if
	
	do
		if ( __fb_keytable(i, 0) = scancode ) then
			return iif(((GetAsyncKeyState(__fb_keytable(i, 1)) or GetAsyncKeyState(__fb_keytable(i, 2))) and &h8000), FB_TRUE, FB_FALSE)
		end if
		i += 1
	loop while (__fb_keytable(i,0))
	return FB_FALSE
end function
end extern