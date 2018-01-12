extern "C"

#ifdef __FB_WIN32__

	'win32/fb_win32.bi #defines fseeko and ftello to these functions
	'In the mingw headers, ftello64 is an inline function, as below.
	'I'm not sure whether these should be in FB's crt headers, or in win32/fb_win32.bi.

	declare function fseeko64 cdecl ( as FILE ptr, as off64_t, as long ) as long

	function ftello64 cdecl (stream as FILE ptr) as off64_t
		dim as fpos_t _pos
		if ( fgetpos(stream, @_pos) ) then
			return  -1
		else
			return (cast(off64_t, _pos))
		end if
	end function

#else

	#ifndef off64_t
		type off64_t as __off64_t
	#endif

	declare function fseeko (byval as FILE ptr, byval as off64_t, byval as long) as long
	declare function ftello (byval as FILE ptr) as off64_t

#endif

end extern
