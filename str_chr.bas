/' chr$ routine '/

#include "fb.bi"
#include "destruct_string.bi"

extern "C"
function fb_CHR cdecl ( dst as FBSTRING ptr, args as long, ... ) as FBSTRING ptr
	dim ap as any ptr
	dim num as ulong
	dim i as long
	dim as destructable_string as tmp_str

	DBG_ASSERT( dst <> NULL )

	if ( args > 0) then
		cva_start( ap, args )

		if ( fb_hStrAlloc( @tmp_str, args ) <> NULL ) then
			dim as ubyte ptr str_data = tmp_str.data
			/' convert '/
			for i = 0 to args - 1
				num = cva_arg( ap, ulong )
				str_data[i] = cast(ubyte, num)
			next
			str_data[args] = 0
		end if
		cva_end( ap )
	end if
	
	fb_StrSwapDesc( dst, @tmp_str )
	return dst
end function
end extern