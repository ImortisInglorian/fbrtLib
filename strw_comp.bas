/' wstring compare function '/

#include "fb.bi"

extern "C"
function fb_WstrCompare FBCALL ( str1 as FB_WCHAR const ptr, str2 as FB_WCHAR const ptr ) as long
	dim as long res
	dim as ssize_t str1_len, str2_len

	/' both not null? '/
	if ( (str1 <> NULL) and (str2 <> NULL) ) then
		str1_len = fb_wstr_Len( str1 )
        str2_len = fb_wstr_Len( str2 )

        res = fb_wstr_Compare( str1, str2, iif((str1_len < str2_len), str1_len, str2_len) )
        if ( (res = 0) and (str1_len <> str2_len) ) then
        	res = iif(( str1_len > str2_len ), 1, -1 )
		end if
        return res
	end if

	/' left null? '/
	if ( str1 = NULL ) then
		/' right also null? return eq '/
		if ( (str2 = NULL) or (fb_wstr_Len( str2 ) = 0) ) then
			return 0
		end if

		/' return lt '/
		return -1
	end if

    /' only right is null. is left empty? return eq '/
    if ( fb_wstr_Len( str1 ) = 0 ) then
    	return 0
	end if

	/' return gt '/
	return 1
end function
end extern