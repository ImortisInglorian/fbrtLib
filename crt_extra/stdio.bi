extern "C"

#ifdef __FB_WIN32__

	'win32/fb_win32.bi #defines fseeko and ftello to these functions
	'In the mingw headers, ftello64 is an inline function, as below.
	'I'm not sure whether these should be in FB's crt headers, or in win32/fb_win32.bi.



	declare function fseeko64 cdecl ( as FILE ptr, as off64_t, as long ) as long
/'
#ifndef ftello64
	function ftello64 cdecl (stream as FILE ptr) as off64_t
		dim as fpos_t _pos
		if ( fgetpos(stream, @_pos) <> NULL ) then
			return  -1
		else
			return (cast(off64_t, _pos))
		end if
	end function
#endif
'/
#else

	#ifndef off64_t
		type off64_t as __off64_t
	#endif

	declare function fseeko (byval as FILE ptr, byval as off64_t, byval as long) as long
	declare function ftello (byval as FILE ptr) as off64_t

#endif

'msvcrt has swprintf/vswprintf functions which differ from POSIX, and FB's
'stdio.bi header is based on mingw/msvcrt. IMO FB ought to try to hide these
'sorts of platform deficiencies to make it easier to write cross-platform code.
#undef swprintf
#undef vswprintf
#ifdef __FB_WIN32__
	declare function swprintf alias "snwprintf" (byval s as wchar_t ptr, byval n as size_t, byval format as wchar_t ptr, ...) as long
	declare function vswprintf  alias "vsnwprintf" (byval s as wchar_t ptr, byval n as size_t, byval format as wchar_t ptr, byval arg as va_list) as long
#else
	declare function swprintf (byval s as wchar_t ptr, byval n as size_t, byval format as wchar_t ptr, ...) as long
	declare function vswprintf (byval s as wchar_t ptr, byval n as size_t, byval format as wchar_t ptr, byval arg as va_list) as long
#endif

end extern
