/' instrrev function '/

#include "fb.bi"

extern "C"
function fb_StrInstrRevAny FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
	dim as ssize_t r = 0

	if ( (src <> NULL) and (src->data <> NULL) and (patt <> NULL) and (patt->data <> NULL) ) then
		dim as ssize_t size_src = FB_STRSIZE(src)
		dim as ssize_t size_patt = FB_STRSIZE(patt)

		if ( (size_src <> 0) and (size_patt <> 0) and (start <> 0) ) then
			if ( start < 0 ) then
				start = size_src
			elseif ( start > size_src ) then
				start = 0
			end if
			
			start -= 1
			while ( start and (r = 0) )
				dim as ssize_t i
				for i = 0 to size_patt
					if ( src->data[start] = patt->data[i] ) then
						r = start + 1
						exit for
					end if
				next
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