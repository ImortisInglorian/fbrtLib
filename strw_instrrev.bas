/' instrrevw function '/

#include "fb.bi"

extern "C"
function fb_WstrInstrRev FBCALL ( src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr, start as ssize_t ) as ssize_t
	if ( (src <> NULL) and (patt <> NULL) ) then
		dim as ssize_t size_src = fb_wstr_Len(src)
		dim as ssize_t size_patt = fb_wstr_Len(patt)
		dim as ssize_t i, j

		if ( (size_src <> 0) and (size_patt <> 0) and (size_patt <= size_src) and (start <> 0)) then
			/' handle signed/unsigned comparisons of start and size_* vars '/
			if ( start < 0 ) then
				start = size_src - size_patt + 1
			elseif ( start > size_src ) then
				start = 0
			elseif (start > size_src - size_patt) then
				start = size_src - size_patt + 1
			end if
			
			/'
				There is no wcsrstr() function, 
				so instead do a brute force scan.
			'/

			for i = 0 to start - 1
				for j = 0 to size_patt
					if ( src[start-i+j-1] <> patt[j] ) then
						exit for
					end if
				next
				if ( j = size_patt ) then
					return start - i
				end if
			next
		end if
	end if
		
	return 0
end function
end extern