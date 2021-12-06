/' console INKEY() function '/

#include "../fb.bi"
#include "fb_private_console.bi"
#include "termcap.bi"

/'#define DEBUG_TGETSTR'/
#ifdef DEBUG_TGETSTR
#include "ctype.bi"
#endif

#define KEY_BUFFER_LEN 256

#define KEY_MOUSE		&H200

Type NODE
	as ubyte key
	as short code
	as NODE ptr next, child
End Type

Type KEY_DATA
	as ubyte ptr cap
	as long code
End Type

/' see also termcap(5) man page '/
static key_data(0 to 24) As const KEY_DATA = { _
	{ sadd("kb"), KEY_BACKSPACE }, _
	{ sadd("kT"), KEY_TAB       }, _
	{ sadd("k1"), KEY_F1        }, _
	{ sadd("k2"), KEY_F2        }, _
	{ sadd("k3"), KEY_F3        }, _
	{ sadd("k4"), KEY_F4        }, _
	{ sadd("k5"), KEY_F5        }, _
	{ sadd("k6"), KEY_F6        }, _
	{ sadd("k7"), KEY_F7        }, _
	{ sadd("k8"), KEY_F8        }, _
	{ sadd("k9"), KEY_F9        }, _
	{ sadd("k;"), KEY_F10       }, _
	{ sadd("F1"), KEY_F11       }, _
	{ sadd("F2"), KEY_F12       }, _
	{ sadd("kh"), KEY_HOME      }, _
	{ sadd("ku"), KEY_UP        }, _
	{ sadd("kP"), KEY_PAGE_UP   }, _
	{ sadd("kl"), KEY_LEFT      }, _
	{ sadd("kr"), KEY_RIGHT     }, _
	{ sadd("@7"), KEY_END       }, _
	{ sadd("kd"), KEY_DOWN      }, _
	{ sadd("kN"), KEY_PAGE_DOWN }, _
	{ sadd("kI"), KEY_INS       }, _
	{ sadd("kD"), KEY_DEL       }, _
	{ NULL, 0 } _
}

Shared Static key_buffer(0 To KEY_BUFFER_LEN - 1) as long
Shared Static key_head, key_tail As long
Shared Static key_buffer_changed As Boolean = False
Shared static root_node As NODE ptr = Null

Private Sub add_key(node as NODE ptr ptr, key as ubyte ptr, code as short)

	dim n as NODE ptr = *node

	/'*
	 * This builds a simple tree that allows fairly easy lookup of the
	 * terminal escape sequences (keys) that were added. For example:
	 *
	 *     after adding these key sequences:
	 *
	 *         [a1, [a2, [b1, [b2
	 *
	 *     the tree looks like:  (| = child, - = sibling)
	 *
	 *         root -> <[>
	 *                  |
	 *                 <b>-----------<a>
	 *                  |             |
	 *                 <2>----<1>    <2>----<1>
	 '/

	While n <> Null
		if (n->key = *key) then
			add_key(@n->child, key + 1, code)
			Exit Sub
		end if
		n = n->next
	Wend
	n = New NODE
	n->child = NULL
	n->next = *node
	n->key = *key
	n->code = 0
	*node = n

	if (*(key + 1)) then
		add_key(@n->child, key + 1, code)
	else
		n->code = code
	end if
End Sub

Private Sub init_keys()

	dim data_ as KEY_DATA ptr = cast(KEY_DATA ptr, key_data)
	dim key as ubyte ptr

	While data_->cap <> Null
		/'*
		 * Lookup the terminal escape sequences (termcap database
		 * entries) corresponding to the id strings defined in the
		 * key_data table above (only key presses here).
		 *
		 * For example, the id string "kh" corresponds to the HOME key,
		 * and tgetstr("kh", NULL) returns the escape sequence that the
		 * terminal will send when the HOME key was pressed.
		 *
		 * These typically vary from terminal to terminal (for example
		 * TERM=xterm vs. TERM=linux) and perhaps depend on other
		 * factors aswell.
		 '/
		key = tgetstr(data->cap, NULL)

#ifdef DEBUG_TGETSTR
		fprintf(stderr, "tgetstr( %s ) =", data->cap)
		if( key ) then
			for( i As Long = 0 to strlen( key ) - 1
				if( isprint( key[i] ) ) then
					fprintf(stderr, " %c", key[i])
				else
					fprintf(stderr, " 0x%2x", key[i])
				end if
			Next
		else
			fprintf(stderr, " (null)")
		end if
		fprintf(stderr, !"\n")
#endif

		if (key) then
			add_key(@root_node, key + 1, data->code)
		end if
		data_ += 1
	Wend
	add_key(@root_node, "[M", KEY_MOUSE)
End Sub

Private Function get_input() as long

	dim node as NODE ptr
	dim as long k, cb, cx, cy

	k = __fb_con.keyboard_getch()
	if (k = asc(!"\&h1b")) then
		k = __fb_con.keyboard_getch()
		if (k = EOF) then
			return 27
		end if

		/' init the tree (on the first received escape sequence) '/
		if (root_node = Null) then
			init_keys()
		end if

		/' look up the escape sequence in the tree '/
		node = root_node
		while (node <> Null)
			if (k = node->key) then
				if (node->code <> 0) then
					if (node->code = KEY_MOUSE) then
						cb = __fb_con.keyboard_getch()
						cx = __fb_con.keyboard_getch()
						cy = __fb_con.keyboard_getch()
						if (__fb_con.mouse_update) then
							__fb_con.mouse_update(cb, cx, cy)
						end if
						return -1
					end if
					return node->code
				end if
				k = __fb_con.keyboard_getch()
				if (k = -1) then
					return -1
				end if
				node = node->child
				continue while
			end if
			node = node->next
		Wend

		/' not found yet, skip rest and ignore '/
		while(__fb_con.keyboard_getch() >= 0)
		Wend

		return -1
	end if

	return k
End Function

Extern "c"
/' assumes BG_LOCK(), because it can be called from the background thread,
   through fb_hTermQuery() '/
Sub fb_hAddCh( k as long )

	if (k = &h7F) then
		k = 8
	elseif (k = asc(!"\n")) then
		k = asc(!"\r")
	end if

	key_buffer(key_tail) = k
	if (((key_tail + 1) And (KEY_BUFFER_LEN - 1)) = key_head) then
		key_head = (key_head + 1) And (KEY_BUFFER_LEN - 1)
	end if
	key_tail = (key_tail + 1) And (KEY_BUFFER_LEN - 1)
	key_buffer_changed = TRUE
End Sub

Function fb_hGetCh(remove As Long) As Long

	dim k as long

	k = get_input()
	if (k >= 0) then
		BG_LOCK()
		fb_hAddCh( k )
		BG_UNLOCK()
	end if
	if (key_head <> key_tail) then
		k = key_buffer[key_head]
		if (remove) then
			key_head = (key_head + 1) And (KEY_BUFFER_LEN - 1)
		end if
	end if

	return k
End Function

/' Caller is expected to hold FB_LOCK() '/
Function fb_ConsoleInkey( ) As FBSTRING ptr

	dim res as FBSTRING ptr
	dim ch as long

	if (__fb_con.inited = 0) Then
		return @__fb_ctx.null_desc
	end if

	ch = fb_hGetCh(TRUE)
	if (ch >= 0) then
		res = fb_hMakeInkeyStr( ch )
	else
		res = @__fb_ctx.null_desc
	end if

	return res
End Function

/' Doing synchronization manually here because getkey() is blocking '/
Function fb_ConsoleGetkey( ) As Long

	dim key as long

	do
		FB_LOCK( )

		if (__fb_con.inited = 0) then
			FB_UNLOCK( )
			return fgetc(stdin)
		end if

		key = fb_hGetCh( TRUE )

		FB_UNLOCK( )

		if( key >= 0 ) then
			Exit do
		end if

		fb_Sleep( -1 )
	loop while( 1 )

	return key
End Function

/' Caller is expected to hold FB_LOCK() '/
Function fb_ConsoleKeyHit( ) As Long

	dim result as long

	if (__fb_con.inited = 0) then
		return Iif( feof(stdin), FALSE, TRUE)
	end if

	fb_hGetCh(FALSE)
	result = key_buffer_changed
	key_buffer_changed = FALSE
	return result
End Function
End Extern
