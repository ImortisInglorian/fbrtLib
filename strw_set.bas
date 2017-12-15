/' lsetw and rsetw functions '/

#include "fb.bi"

extern "C"
sub fb_WstrLset FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
	dim as ssize_t slen, dlen, _len

	if ( (dst <> NULL) and (src <> NULL) ) then
		slen = fb_wstr_Len( src )
		dlen = fb_wstr_Len( dst )

		if ( dlen > 0 ) then
			_len = iif(dlen <= slen, dlen, slen )

			fb_wstr_Copy( dst, src, _len )

			_len = dlen - slen
			if ( _len > 0 ) then
				fb_wstr_Fill( @dst[slen], 32, _len )
			end if
		end if
	end if
end sub

sub fb_WstrRset FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
	dim as ssize_t slen, dlen, _len, padlen

	if ( (dst <> NULL) and (src <> NULL) ) then
		slen = fb_wstr_Len( src )
		dlen = fb_wstr_Len( dst )

		if ( dlen > 0 ) then
			padlen = dlen - slen
			if ( padlen > 0 ) then
				fb_wstr_Fill( dst, 32, padlen )
			else
				padlen = 0
			end if

			_len = iif(dlen <= slen, dlen, slen )

			fb_wstr_Copy( @dst[padlen], src, _len )
		end if
	end if
end sub
end extern