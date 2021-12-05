#ifndef DISABLE_X11

#include "X11/Xlib.bi"
#include "X11/keysym.bi"

Type XOPENDISPLAY As Function(as ubyte ptr) as Display ptr
Type XCLOSEDISPLAY As Function (as Display ptr) as long
Type XQUERYKEYMAP As Sub(as Display ptr, as ubyte ptr)
Type XDISPLAYKEYCODES As Function(as Display ptr, as long ptr, as long ptr) as long
Type XGETKEYBOARDMAPPING As Function(as Display ptr, as KeyCode, as long, as long ptr) as KeySym ptr
Type XFREE as Function(as Any ptr) as long

extern fb_x11keycode_to_scancode(0 to 255) as ubyte

Declare Sub fb_hInitX11KeycodeToScancodeTb
	(
		display_ as Display ptr,
		DisplayKeycodes as XDISPLAYKEYCODES,
		GetKeyboardMapping as XGETKEYBOARDMAPPING,
		free as XFREE
	)

#endif
