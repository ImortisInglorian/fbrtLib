type _FB_FILE as FB_FILE
type _FBSTRING as FBSTRING
type FB_INPUTCTX
	as _FB_FILE ptr handle
	as long status
	as _FBSTRING str
	as long index
end type

declare function fb_get_thread_inputctx( ) as FB_INPUTCTX ptr