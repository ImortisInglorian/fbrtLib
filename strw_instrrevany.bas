/' instrrevanyw function '/

#include "fb.bi"

extern "C"
function fb_WstrInstrRevAny FBCALL ( src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr, start as ssize_t ) as ssize_t
	if ( (src <> NULL) and (patt <> NULL) ) then
		dim as ssize_t size_src = fb_wstr_Len(src)
		dim as ssize_t size_patt = fb_wstr_Len(patt)
		dim as ssize_t i

		if ( (size_src <> 0) and (size_patt <> 0) and (start <> 0)) then
			if ( start < 0 ) then
				start = size_src
			elseif ( start > size_src ) then
				start = 0
			end if

			start -= 1
			while ( start <> 0 )
				for i = 0 to size_patt
					if ( src[start] = patt[i] ) then
						return start + 1
					end if
				next
				start -= 1
			wend
		end if
	end if

	return 0
end function
end extern