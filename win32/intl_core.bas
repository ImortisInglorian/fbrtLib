/' Core i18n functions '/

#include "../fb.bi"
#include "fb_private_intl.bi"

extern "C"
/' Convert a strings character set to another character set. '/
private function fb_hIntlConvertToWC( source as FBSTRING ptr, source_cp as UINT ) as FBSTRING ptr
    dim as FBSTRING ptr res
    dim as long CharsRequired

    FB_STRLOCK()

    CharsRequired = MultiByteToWideChar( source_cp, 0, source->data, FB_STRSIZE(source), NULL, 0 )

    res = fb_hStrAllocTemp_NoLock( NULL, (CharsRequired + 1) * sizeof(WCHAR) - 1 )
    if ( res <> NULL ) then
        dim as size_t idx = CharsRequired * sizeof(WCHAR)
        MultiByteToWideChar( source_cp, 0, cast(LPCSTR, source->data), FB_STRSIZE(source), cast(LPWSTR, res->data), CharsRequired )
        *(cast(WCHAR ptr, (res->data + idx))) = 0
    else
        res = @__fb_ctx.null_desc
    end if

    fb_hStrDelTemp_NoLock( source )

    FB_STRUNLOCK()

    return res
end function

private function fb_hIntlConvertFromWC( source as FBSTRING ptr, dest_cp as UINT ) as FBSTRING ptr
    dim as FBSTRING ptr res
    dim as long CharsRequired

    FB_STRLOCK()

    CharsRequired = WideCharToMultiByte( dest_cp, 0, cast(LPCWSTR, source->data), FB_STRSIZE(source) / sizeof(WCHAR), cast(LPSTR, NULL), 0, NULL, NULL )

    res = fb_hStrAllocTemp_NoLock( NULL, CharsRequired )
    if ( res <> NULL ) then
        WideCharToMultiByte( dest_cp, 0, cast(LPCWSTR, source->data), FB_STRSIZE(source) / sizeof(WCHAR), cast(LPSTR, res->data), CharsRequired, NULL, NULL )
        res->data[CharsRequired] = 0
    else
        res = @__fb_ctx.null_desc
    end if

    fb_hStrDelTemp_NoLock( source )

    FB_STRUNLOCK()

    return res
end function

function fb_hIntlConvertString( source as FBSTRING ptr, source_cp as long, dest_cp as long ) as FBSTRING ptr
	return fb_hIntlConvertFromWC( fb_hIntlConvertToWC( source, source_cp ), dest_cp )
end function

function fb_hGetLocaleInfo( Locale as LCID, _LCType as LCTYPE, pszBuffer as ubyte ptr, uiSize as size_t ) as ubyte ptr
    if ( uiSize = 0 ) then
        uiSize = 64
        pszBuffer = NULL
        do
			uiSize shl= 1
            pszBuffer = cast(ubyte ptr, realloc( pszBuffer, uiSize ))
            if ( pszBuffer = NULL ) then
                exit do
			end if
            if ( GetLocaleInfo( Locale, _LCType, pszBuffer, uiSize - 1 ) <> 0 ) then
                return pszBuffer
            end if
            if ( GetLastError( ) <> ERROR_INSUFFICIENT_BUFFER ) then
                free( pszBuffer )
                pszBuffer = NULL
                exit do
            end if
        loop
    else
        if ( GetLocaleInfo( Locale, _LCType, pszBuffer, uiSize ) <> 0 ) then
            return pszBuffer
		end if
    end if
    return NULL
end function
end extern