#define PUT_MODE_TRANS 		0
#define PUT_MODE_PSET 		1
#define PUT_MODE_PRESET		2
#define PUT_MODE_AND 		3
#define PUT_MODE_OR			4
#define PUT_MODE_XOR 		5
#define PUT_MODE_ALPHA 		6
#define PUT_MODE_ADD 		7
#define PUT_MODE_CUSTOM 	8
#define PUT_MODE_BLEND 		9
#define PUT_MODES 			10

type BLENDER as  function FBCALL (as ulong, as ulong, as any ptr) as ulong
type PUTTER as sub ( as ubyte ptr, as ubyte ptr, as long, as long, as long, as long, as long, as BLENDER ptr, as any ptr)


type FB_GFXCTX
	as long id
	as long work_page
	as ubyte ptr ptr line
	as long max_h
	as long target_bpp
	as long target_pitch
	as any ptr last_target
	as single last_x
	as single last_y
	union
		type
			as long view_x
			as long view_y
			as long view_w
			as long view_h
		end type
		as long view(0 to 3)
	end union
	union
		type
			as long old_view_x
			as long old_view_y
			as long old_view_w
			as long old_view_h
		end type
		as long old_view(0 to 3)
	end union
	as single win_x
	as single win_y
	as single win_w
	as single win_h
	as ulong fg_color
	as ulong bg_color
	as sub ( ctx as FB_GFXCTX ptr, x as long, y as long, _color as ulong ) put_pixel
	as function( ctx as FB_GFXCTX ptr, x as long, y as long ) as ulong get_pixel
	as function( dest as any ptr, _color as long, size as size_t) as any ptr pixel_set
	as PUTTER putter(0 to PUT_MODES - 1)
	as long flags
end type
