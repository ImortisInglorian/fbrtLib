/' swap for strings '/

#include "fb.bi"

extern "C"
sub fb_StrSwap FBCALL ( str1 as any ptr, size1 as ssize_t, fillrem1 as long, str2 as any ptr, size2 as ssize_t, fillrem2 as long )
	dim as ubyte ptr p1, p2
	dim as ssize_t len1, len2

	if ( (str1 = NULL) or (str2 = NULL) ) then
		exit sub
	end if

	/' both var-len? '/
	if ( (size1 = FB_STRSIZEVARLEN) and (size2 = FB_STRSIZEVARLEN) ) then
		dim as FBSTRING td

		/' just swap the descriptors '/
		td.data = (cast(FBSTRING ptr, str1)->data)
		td.len  = (cast(FBSTRING ptr, str1)->len)
		td.size  = (cast(FBSTRING ptr, str1)->size)

		cast(FBSTRING ptr, str1)->data = cast(FBSTRING ptr, str2)->data
		cast(FBSTRING ptr, str1)->len = cast(FBSTRING ptr, str2)->len
		cast(FBSTRING ptr, str1)->size = cast(FBSTRING ptr, str2)->size

		cast(FBSTRING ptr, str2)->data = td.data
		cast(FBSTRING ptr, str2)->len = td.len
		cast(FBSTRING ptr, str2)->size = td.size

		exit sub
	end if

	FB_STRSETUP_FIX( str1, size1, p1, len1 )
	FB_STRSETUP_FIX( str2, size2, p2, len2 )

	/' Same length? Only need to do an fb_MemSwap() '/
	if ( len1 = len2 ) then
		if ( len1 > 0 ) then
			fb_MemSwap( cast(ubyte ptr, p1), cast(ubyte ptr, p2), len1 )
			/' null terminators don't need to change '/
		end if
		exit sub
	end if

	/' Note: user-allocated zstrings are assumed to be large enough '/

	/' Is one of them a var-len string? Might need to be (re)allocated '/
	if ( (size1 = FB_STRSIZEVARLEN) or (size2 = FB_STRSIZEVARLEN) ) then
		dim as FBSTRING td = ( 0, 0, 0 )
		fb_StrAssign( @td, FB_STRSIZEVARLEN, str1, size1, FALSE )
		fb_StrAssign( str1, size1, str2, size2, fillrem1 )
		fb_StrAssign( str2, size2, @td, FB_STRSIZEVARLEN, fillrem2 )
		fb_StrDelete( @td )
		exit sub
	end if

	/' Both are fixed-size/user-allocated [z]strings '/

	/' Make str1/str2 be the smaller/larger string respectively '/
	if ( len1 > len2 ) then
		scope
			dim as ubyte ptr p = p1
			p1 = p2
			p2 = p
		end scope

		scope
			dim as ssize_t _len = len1
			len1 = len2
			len2 = _len
		end scope

		scope
			dim as ssize_t size = size1
			size1 = size2
			size2 = size
		end scope

		scope
			dim as long fillrem = fillrem1
			fillrem1 = fillrem2
			fillrem2 = fillrem
		end scope
	end if

	/' MemSwap as much as possible (i.e. the smaller length) '/
	if ( len1 > 0 ) then
		fb_MemSwap( cast(ubyte ptr, p1), cast(ubyte ptr, p2), len1 )
	end if

	/' copy the remainder '/

	/' zstring -> zstring '/
	if( (size1 >= 0) andalso (size2 >= 0) ) then
		/' and copy over the remainder from larger to smaller, unless it's
		   a fixed-size [z]string that doesn't have enough room left (not even
		   for the null terminator) '/
		if( (size1 > 0) andalso (len2 >= size1) ) then
			len2 = len1
		elseif( len2 > len1 ) then
			FB_MEMCPYX( cast(ubyte ptr, (p1 + len1)), cast(ubyte ptr, (p2 + len1)), len2 - len1 )
		end if
	
		p1[len2] = 0
		p2[len1] = 0
	
		/' Clear remainder of the larger (now smaller) string with nulls if
		   requested (see also fb_StrAssign()). We can assume that the strings
		   were originally cleared properly, because uninitialized strings
		   mustn't be used in rvalues, FB_STRSETUP_FIX() doesn't handle that.
		   The smaller (now larger) string doesn't need to be touched, as it's
		   remainder didn't increase '/
		if( fillrem2 ) then
			dim as ssize_t used2 = len1
			if( size2 > used2 ) then
				memset( p2 + used2, 0, size2 - used2 )
			end if
		end if

	/' string  -> string '/
	elseif( (size1 and FB_STRISFIXED) andalso (size2 and FB_STRISFIXED) ) then
		if( (len2 - len1) > 0 ) then
			memset( cast(ubyte ptr, p2) + len1, 32, len2 - len1 )
		end if 

	/' string  -> zstring '/
	elseif ( (size1 and FB_STRISFIXED) andalso (size2 > 0 ) ) then
		p2[len1] = 0

	/' zstring -> string '/
	elseif( (size1 >= 0) andalso (size2 and FB_STRISFIXED) ) then
		if( (size1 > 0) andalso (len2 >= size1) ) then
			len2 = len1
		elseif( len2 > len1 ) then
			FB_MEMCPYX( cast(ubyte ptr, (p1 + len1)), cast(ubyte ptr, (p2 + len1)), len2 - len1 )
		end if

		p1[len2] = 0

		if( (len2 - size1) > 0 ) then
			memset( p2 + len1, 32, len2 - size1 )
		end if 

	end if
end sub
end extern