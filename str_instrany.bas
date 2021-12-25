/' instrany function '/

#include "fb.bi"

extern "C"
function fb_StrInstrAny FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
	dim as ssize_t r

	if ( (src = NULL) orelse (src->data = NULL) orelse (patt = NULL) orelse (patt->data = NULL) ) then
		r = 0
	else
		dim as ssize_t size_src = FB_STRSIZE(src)
		dim as ssize_t size_patt = FB_STRSIZE(patt)

		if ( (size_src = 0) or (size_patt = 0) or (start < 1) or (start > size_src) ) then
			r = 0
		else
			dim as ssize_t i, found, search_len = size_src - start + 1
			dim as const ubyte ptr pachText = src->data + start - 1
			r = search_len
			
			i = 0
			while( i <> size_patt )
				dim as const ubyte ptr pszEnd = cast(const ubyte ptr, FB_MEMCHR( pachText, patt->data[i], r ))
				if ( pszEnd <> NULL ) then
					found = pszEnd - pachText
					if ( found < r ) then
						r = found
					end if
				end if
				i += 1
			wend
			if ( r = search_len ) then
				r = 0
			else 
				r += start
			end if
		end if
	end if

	return r
end function
end extern