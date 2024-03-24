/' lset and rset functions '/

#include "fb.bi"

extern "C"
sub fb_StrLset FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
	dim as ssize_t slen, dlen, _len

	if ( (dst <> NULL) and (dst->data <> NULL) and (src <> NULL) ) then
		slen = FB_STRSIZE( src )
		dlen = FB_STRSIZE( dst )

		if ( dlen > 0 ) then
			_len = iif( dlen <= slen, dlen, slen )

			fb_hStrCopy( dst->data, src->data, _len )

			_len = dlen - slen
			if ( _len > 0 ) then
				memset( @dst->data[slen], 32, _len )

				/' null char '/
				dst->data[slen + _len] = 0
			end if
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( src )

	/' del if temp '/
	fb_hStrDelTemp( dst )
end sub

'' LSET fixed length string from var-len string
sub fb_StrLsetANA ( dst as any ptr, dst_size as ssize_t, src as FBSTRING ptr )
	dim as ssize_t slen = any, dlen = any, _len = any

	if( (dst <> NULL) andalso (src <> NULL) ) then
		slen = FB_STRSIZE( src )
		dlen = dst_size and FB_STRSIZEMSK

		if( dlen > 0 ) then
			_len = iif (dlen <= slen, dlen, slen )

			fb_hStrCopyN( dst, src->data, _len )

			_len = dlen - slen
			if( _len > 0 ) then
				memset( dst + slen, 32, _len )
			end if
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( src )
end sub

sub fb_StrRset FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
	dim as ssize_t slen, dlen, _len, padlen

	if ( (dst <> NULL) and (dst->data <> NULL) and (src <> NULL) ) then
		slen = FB_STRSIZE( src )
		dlen = FB_STRSIZE( dst )

		if ( dlen > 0 ) then
			padlen = dlen - slen
			if ( padlen > 0 ) then
				memset( dst->data, 32, padlen )
			else
				padlen = 0
			end if

			_len = iif( dlen <= slen, dlen, slen )

			fb_hStrCopy( @dst->data[padlen], src->data, _len )
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( src )

	/' del if temp '/
	fb_hStrDelTemp( dst )
end sub

'' RSET fixed length string from var-len string
sub fb_StrRsetANA ( dst as any ptr, dst_size as ssize_t, src as FBSTRING ptr )
	dim as ssize_t slen = any, dlen = any, _len = any, padlen = any

	if( (dst <> NULL) andalso (src <> NULL) ) then
		slen = FB_STRSIZE( src )
		dlen = dst_size and FB_STRSIZEMSK

		if( dlen > 0 ) then
			padlen = dlen - slen
			if( padlen > 0 ) then
				memset( dst, 32, padlen )
			else
				padlen = 0
			end if

			_len = iif( dlen <= slen, dlen, slen )

			fb_hStrCopyN( dst + padlen, src->data, _len )
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( src )
end sub
end extern