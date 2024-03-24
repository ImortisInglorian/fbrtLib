/' string compare function '/

#include "fb.bi"

extern "C"
function fb_StrCompare FBCALL ( str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as long
	dim as const ubyte ptr str1_ptr, str2_ptr
	dim as ssize_t str1_len, str2_len
	dim res as long

	/' both not null? '/
	if ( (str1 <> NULL) and (str2 <> NULL) ) then
		FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )
		FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

		res = FB_MEMCMP( str1_ptr, str2_ptr, (iif(str1_len < str2_len, str1_len, str2_len) ) )

		if ( (res = 0) and (str1_len <> str2_len) ) then
			res = (iif( str1_len > str2_len, 1, -1 ))
		end if
		/' left null? '/
	elseif ( str1 = NULL ) then
		/' right also null? return eq '/
		if ( str2 = NULL ) then
			res = 0
		else
			FB_STRSETUP_FIX( str2, str2_size, str2_ptr, str2_len )

			/' is right empty? return eq '/
			if ( str2_len = 0 ) then
				res = 0
			/' else, return lt '/
			else
				res = -1
			end if
		end if
	/' only right is null '/
	else
		FB_STRSETUP_FIX( str1, str1_size, str1_ptr, str1_len )

		/' is left empty? return eq '/
		if ( str1_len = 0 ) then
			res = 0
			/' else, return gt '/
		else
			res = 1
		end if
	end if


	FB_STRLOCK()

	/' delete temps? '/
	if ( str1_size = FB_STRSIZEVARLEN ) then
		fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, str1) )
	end if
	if ( str2_size = FB_STRSIZEVARLEN ) then
		fb_hStrDelTemp_NoLock( cast(FBSTRING ptr, str2) )
	end if

	FB_STRUNLOCK()

	return res
end function
end extern