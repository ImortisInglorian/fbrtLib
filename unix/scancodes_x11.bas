#include "../fb.bi"
#include "fb_private_scancodes_x11.bi"

#ifndef DISABLE_X11

Type KeysymToScancode 
	as KeySym keysym
	as long scancode
End Type

static shared keysym_to_scancode(0 to 104) as const KeysymToScancode = _
{ _
	{ XK_Escape      , SC_ESCAPE       }, _
	{ XK_F1          , SC_F1           }, _
	{ XK_F2          , SC_F2           }, _
	{ XK_F3          , SC_F3           }, _
	{ XK_F4          , SC_F4           }, _
	{ XK_F5          , SC_F5           }, _
	{ XK_F6          , SC_F6           }, _
	{ XK_F7          , SC_F7           }, _
	{ XK_F8          , SC_F8           }, _
	{ XK_F9          , SC_F9           }, _
	{ XK_F10         , SC_F10          }, _
	{ XK_F11         , SC_F11          }, _
	{ XK_F12         , SC_F12          }, _
	{ XK_Scroll_Lock , SC_SCROLLLOCK   }, _
	{ XK_grave       , SC_TILDE        }, _
	{ XK_quoteleft   , SC_TILDE        }, _
	{ XK_asciitilde  , SC_TILDE        }, _
	{ XK_1           , SC_1            }, _
	{ XK_2           , SC_2            }, _
	{ XK_3           , SC_3            }, _
	{ XK_4           , SC_4            }, _
	{ XK_5           , SC_5            }, _
	{ XK_6           , SC_6            }, _
	{ XK_7           , SC_7            }, _
	{ XK_8           , SC_8            }, _
	{ XK_9           , SC_9            }, _
	{ XK_0           , SC_0            }, _
	{ XK_minus       , SC_MINUS        }, _
	{ XK_equal       , SC_EQUALS       }, _
	{ XK_backslash   , SC_BACKSLASH    }, _
	{ XK_BackSpace   , SC_BACKSPACE    }, _
	{ XK_Tab         , SC_TAB          }, _
	{ XK_q           , SC_Q            }, _
	{ XK_w           , SC_W            }, _
	{ XK_e           , SC_E            }, _
	{ XK_r           , SC_R            }, _
	{ XK_t           , SC_T            }, _
	{ XK_y           , SC_Y            }, _
	{ XK_u           , SC_U            }, _
	{ XK_i           , SC_I            }, _
	{ XK_o           , SC_O            }, _
	{ XK_p           , SC_P            }, _
	{ XK_bracketleft , SC_LEFTBRACKET  }, _
	{ XK_bracketright, SC_RIGHTBRACKET }, _
	{ XK_Return      , SC_ENTER        }, _
	{ XK_Caps_Lock   , SC_CAPSLOCK     }, _
	{ XK_a           , SC_A            }, _
	{ XK_s           , SC_S            }, _
	{ XK_d           , SC_D            }, _
	{ XK_f           , SC_F            }, _
	{ XK_g           , SC_G            }, _
	{ XK_h           , SC_H            }, _
	{ XK_j           , SC_J            }, _
	{ XK_k           , SC_K            }, _
	{ XK_l           , SC_L            }, _
	{ XK_semicolon   , SC_SEMICOLON    }, _
	{ XK_apostrophe  , SC_QUOTE        }, _
	{ XK_Shift_L     , SC_LSHIFT       }, _
	{ XK_z           , SC_Z            }, _
	{ XK_x           , SC_X            }, _
	{ XK_c           , SC_C            }, _
	{ XK_v           , SC_V            }, _
	{ XK_b           , SC_B            }, _
	{ XK_n           , SC_N            }, _
	{ XK_m           , SC_M            }, _
	{ XK_comma       , SC_COMMA        }, _
	{ XK_period      , SC_PERIOD       }, _
	{ XK_slash       , SC_SLASH        }, _
	{ XK_Shift_R     , SC_RSHIFT       }, _
	{ XK_Control_L   , SC_CONTROL      }, _
	{ XK_Meta_L      , SC_LWIN         }, _
	{ XK_Alt_L       , SC_ALT          }, _
	{ XK_space       , SC_SPACE        }, _
	{ XK_Alt_R       , SC_ALT          }, _
	{ XK_Meta_R      , SC_RWIN         }, _
	{ XK_Menu        , SC_MENU         }, _
	{ XK_Control_R   , SC_CONTROL      }, _
	{ XK_Insert      , SC_INSERT       }, _
	{ XK_Home        , SC_HOME         }, _
	{ XK_Prior       , SC_PAGEUP       }, _
	{ XK_Delete      , SC_DELETE       }, _
	{ XK_End         , SC_END          }, _
	{ XK_Next        , SC_PAGEDOWN     }, _
	{ XK_Up          , SC_UP           }, _
	{ XK_Left        , SC_LEFT         }, _
	{ XK_Down        , SC_DOWN         }, _
	{ XK_Right       , SC_RIGHT        }, _
	{ XK_Num_Lock    , SC_NUMLOCK      }, _
	{ XK_KP_Divide   , SC_SLASH        }, _
	{ XK_KP_Multiply , SC_MULTIPLY     }, _
	{ XK_KP_Subtract , SC_MINUS        }, _
	{ XK_KP_Home     , SC_HOME         }, _
	{ XK_KP_Up       , SC_UP           }, _
	{ XK_KP_Prior    , SC_PAGEUP       }, _
	{ XK_KP_Add      , SC_PLUS         }, _
	{ XK_KP_Left     , SC_LEFT         }, _
	{ XK_KP_Begin    , SC_CLEAR        }, _
	{ XK_KP_Right    , SC_RIGHT        }, _
	{ XK_KP_End      , SC_END          }, _
	{ XK_KP_Down     , SC_DOWN         }, _
	{ XK_KP_Next     , SC_PAGEDOWN     }, _
	{ XK_KP_Enter    , SC_ENTER        }, _
	{ XK_KP_Insert   , SC_INSERT       }, _
	{ XK_KP_Delete   , SC_DELETE       }, _
	{ NoSymbol       , 0               } _
}

Dim fb_x11keycode_to_scancode(0 to 255) as ubyte

Sub fb_hInitX11KeycodeToScancodeTb _
	( _
		display_ as Display ptr, _
		DisplayKeycodes as XDISPLAYKEYCODES, _
		GetKeyboardMapping as XGETKEYBOARDMAPPING, _
		Free as XFREE  _
	)

	dim as long keycode_min, keycode_max, i, j
	dim as long keysyms_per_keycode_return

	DisplayKeycodes( display_, @keycode_min, @keycode_max )
	if( keycode_min < 0   ) then keycode_min = 0
	if( keycode_max > 255 ) then keycode_max = 255

	for i = keycode_min to keycode_max
		dim keysyms as KeySym ptr = GetKeyboardMapping( display_, i, 1, @keysyms_per_keycode_return )

		KeySym keysym = keysyms[0]
		if( keysym <> NoSymbol ) then
			j = 0
			while keysym_to_scancode(j).scancode <> 0 AndAlso _
				keysym_to_scancode(j).keysym <> keysym)
				j += 1
			wend
			fb_x11keycode_to_scancode(i) = keysym_to_scancode(j).scancode
		end if

		Free( keysyms )
	Next
End Sub

#endif
