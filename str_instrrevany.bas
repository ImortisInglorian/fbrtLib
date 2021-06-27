/' instrrev function '/

#include "fb.bi"

extern "C"
function fb_StrInstrRevAny FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
	dim as ssize_t r = 0

	if ( (src <> NULL) andalso (src->data <> NULL) andalso (patt <> NULL) andalso (patt->data <> NULL) ) then
		dim as ssize_t size_src = FB_STRSIZE(src)
		dim as ssize_t size_patt = FB_STRSIZE(patt)

		if ( (size_src <> 0) and (size_patt <> 0) and (start <> 0) ) then
			if ( start < 0 ) then
				start = size_src
			elseif ( start > size_src ) then
				start = 0
			end if
			
			while ( (start <> 0) andalso (r = 0) )
				dim as ssize_t i = 0
				while( i <> size_patt )
					if ( src->data[start] = patt->data[i] ) then
						r = start + 1
						exit while
					end if
					i += 1
				wend
				start -= 1
			wend
		end if
	end if

	FB_STRLOCK()

	/' del if temp '/
	fb_hStrDelTemp_NoLock( src )
	fb_hStrDelTemp_NoLock( patt )

	FB_STRUNLOCK()

	return r
end function
end extern