/' XTerm focus query helpers '/

#include "../fb.bi"

#ifndef DISABLE_X11
#include "../fb_private_hdynload.bi"
#include "X11/Xlib.bi"
#include "fb_private_scancodes_x11.bi"

type XGETINPUTFOCUS as Function(as Display ptr, as Window ptr, as long ptr) as long

Type X_FUNCS
	OpenDisplay as XOPENDISPLAY
	CloseDisplay as XCLOSEDISPLAY
	GetInputFocus As XGETINPUTFOCUS
End Type

static shared ref_count as long = 0
static shared xlib as FB_DYLIB
static shared X as X_FUNCS
static shared display as Display ptr
static shared xterm_window as Window
#endif

Function fb_hXTermInitFocus() as long

#ifndef DISABLE_X11
	dim funcs(0 To 3) as const ubyte ptr = { _
		sadd("XOpenDisplay"), _
		sadd("XCloseDisplay"), _
		sadd("XGetInputFocus"), _
		NULL _
	}
	dim dummy as long

	ref_count += 1
	if (ref_count > 1) then
		return 0
	end if

	xlib = fb_hDynLoad(sadd("libX11.so"), @funcs(0), cast(any ptr ptr, @X))
	if (xlib = Null) then
		return -1
	end if

	display = X.OpenDisplay(NULL)
	if (display = Null) then
		return -1
	end if

	X.GetInputFocus(display, @xterm_window, @dummy)
#endif
	return 0
End Function

Sub fb_hXTermExitFocus()

#ifndef DISABLE_X11
	ref_count -= 1
	if (ref_count > 0) then
		Exit Sub
	end if
	X.CloseDisplay(display)
	fb_hDynUnload(@xlib)
#endif
End Sub

Function fb_hXTermHasFocus() as long

#ifndef DISABLE_X11
	dim focus_window as Window
	dim dummy as long

	X.GetInputFocus(display, @focus_window, @dummy)

	return (focus_window = xterm_window)
#else
	return 0
#endif
End Function
