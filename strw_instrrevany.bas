/' instrrevanyw function '/

#include "fb.bi"

extern "C"
function fb_WstrInstrRevAny FBCALL ( src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr, start as ssize_t ) as ssize_t
	if ( (src <> NULL) andalso (patt <> NULL) ) then
		dim as ssize_t size_src = fb_wstr_Len(src)
		dim as ssize_t size_patt = fb_wstr_Len(patt)
		dim as ssize_t i

		if ( (size_src <> 0) andalso (size_patt <> 0) andalso (start <> 0)) then
			if ( start < 0 ) then
				start = size_src
			elseif ( start > size_src ) then
				start = 0
			end if

			while ( start <> 0 )
				start -= 1
				i = 0
				while( i <> size_patt )
					if ( src[start] = patt[i] ) then
						return start + 1
					end if
					i += 1
				wend
			wend
		end if
	end if

	return 0
end function
end extern