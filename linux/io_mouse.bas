/' console mode mouse functions '/

#include "../fb.bi"

#ifdef DISABLE_GPM

Extern "c"
Function fb_ConsoleGetMouse( x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr ) as long

	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End Function
End Extern

#else

#include "../unix/fb_private_console.bi"
#include "../fb_private_hdynload.bi"
#include "sys/select.bi"
#include "gpm.bi"

Type GPM_OPEN as Function(x as Gpm_Connect ptr, y as long) as long
Type GPM_CLONE as Function() As Long
Type GPM_GETEVENT as Function (x as Gpm_Event ptr) as long

Type GPM_FUNCS
	as GPM_OPEN Open
	as GPM_CLOSE Close
	as GPM_GETEVENT GetEvent
	as long ptr fd
End Type

static shared gpm_lib as FB_DYLIB = NULL
static shared gpm as GPM_FUNCS
static shared conn as Gpm_Connect
static shared has_focus as Boolean = TRUE
static shared as long mouse_x = 0, mouse_y = 0, mouse_z = 0, mouse_buttons = 0

Private Sub mouse_update(cb as long, cx as long, cy as long)

	if (has_focus) then
		cb And= Not &H1C
		if (cb >= &H60) then
			if (cb - &H60) then
				mouse_z -= 1
			else
				mouse_z += 1
			end if
		else
			if (cb >= &h40) then
				cb -= &h20
			end if
			select case cb
				case &h20 mouse_buttons Or= &h1
				case &h21 mouse_buttons Or= &h4
				case &h22 mouse_buttons Or= &h2
				case &h23 mouse_buttons = 0
			end select
		end if
		mouse_x = cx - &h21
		mouse_y = cy - &h21
	end if
End Sub

Private Sub mouse_handler()

	din event as Gpm_Event
	dim set as fd_set
	dim tv as timeval = { 0, 0 }
	dim count as long = 0

#ifndef DISABLE_X11
	if (__fb_con.inited = INIT_X11) then
		if (fb_hXTermHasFocus()) then
			if (has_focus = False) then mouse_buttons = 0 
			has_focus = TRUE
		else
			if (has_focus) then
				mouse_x = -1
				mouse_y = -1
				mouse_buttons = -1
			end if
			has_focus = FALSE
		end if
		Exit Sub
	end if
#endif

	FD_ZERO(&set)
	FD_SET(*gpm.fd, &set)

	while ((select(FD_SETSIZE, @set, NULL, NULL, @tv) > 0) AndAlso (count < 16))
		if (gpm.GetEvent(@event) > 0) then
			mouse_x += event.dx
			mouse_y += event.dy

			fb_hRecheckConsoleSize( TRUE )
			if (mouse_x < 0) then mouse_x = 0
			if (mouse_x >= __fb_con.w) then mouse_x = __fb_con.w - 1
			if (mouse_y < 0) then mouse_y = 0
			if (mouse_y >= __fb_con.h) then mouse_y = __fb_con.h - 1

			mouse_z += event.wdy

			if (event.type And GPM_DOWN) then
				mouse_buttons Or= _
					((event.buttons And &h4) Shr 2) Or _
					((event.buttons And &h2) Shl 1) Or _
					((event.buttons And &h1) Shl 1)
			elseif (event.type And GPM_UP) then
				mouse_buttons And= Not _
					((event.buttons And &h4) Shr 2) Or _
					((event.buttons And &h2) Shl 1) Or _
					((event.buttons And &h1) Shl 1)
			end if
		end if
		count += 1
	Wend
End Sub

Private Function mouse_init() as long

	dim funcs(0 to 4) as ubyte ptr = { sadd("Gpm_Open"), sadd("Gpm_Close"), sadd("Gpm_GetEvent"), sadd("gpm_fd"), NULL }

	if (__fb_con.inited = INIT_CONSOLE) then
		gpm_lib = fb_hDynLoad("libgpm.so.1", funcs, cast(any ptr ptr, @gpm))
		if (gpm_lib = Null) then return -1

		conn.eventMask = Not 0
		conn.defaultMask = Not GPM_HARD
		conn.maxMod = Not 0
		conn.minMod = 0
		if (gpm.Open(@conn, 0) < 0) then
			fb_hDynUnload(@gpm_lib)
			return -1
		end if
	else
		fb_hTermOut(SEQ_INIT_XMOUSE, 0, 0)
		__fb_con.mouse_update = mouse_update
#ifndef DISABLE_X11
		fb_hXTermInitFocus()
#endif
	end if
	return 0
End Function

Private Sub mouse_exit()

	if (__fb_con.inited = INIT_CONSOLE) then
		gpm.Close()
		fb_hDynUnload(@gpm_lib)
	
	else
		fb_hTermOut(SEQ_EXIT_XMOUSE, 0, 0)
#ifndef DISABLE_X11
		fb_hXTermExitFocus()
#endif
		__fb_con.mouse_update = NULL
	end if
	__fb_con.mouse_handler = NULL
	__fb_con.mouse_exit = NULL
End Sub

Extern "c"
Function fb_ConsoleGetMouse(x as long ptr, y as long ptr, z as long ptr, buttons as long ptr, clip as long ptr) as long

	dim as long temp_z, temp_buttons

	if (__fb_con.inited = 0) then
		return fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
	end if

	if (z = Null) then z = @temp_z
	if (buttons = Null) then buttons = @temp_buttons

	BG_LOCK()

	fb_hStartBgThread( )

	if (!__fb_con.mouse_handler) then
		if (mouse_init() = 0) then
			__fb_con.mouse_init = mouse_init
			__fb_con.mouse_exit = mouse_exit
			__fb_con.mouse_handler = mouse_handler
		else
			*x = -1 : *y = -1 : *z = -1 : *buttons = -1
			BG_UNLOCK()
			return fb_ErrorSetNum(FB_RTERROR_ILLEGALFUNCTIONCALL)
		end if
	end if

	if (__fb_con.inited <> INIT_CONSOLE) then
		fb_hGetCh(FALSE)
	end if

	*x = mouse_x
	*y = mouse_y
	*z = mouse_z
	*buttons = mouse_buttons
	*clip = 0

	BG_UNLOCK()

	return FB_RTERROR_OK
End Function
End Extern

#endif /' ndef DISABLE_GPM '/

Extern "c"
Function fb_ConsoleSetMouse( x as long, y as long, cursor as long, clip as long ) as long

	return fb_ErrorSetNum( FB_RTERROR_ILLEGALFUNCTIONCALL )
End If
End Extern
