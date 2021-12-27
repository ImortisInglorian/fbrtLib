/' Core i18n functions '/

#include "../fb.bi"
#include "fb_private_intl.bi"
#include "../destruct_string.bi"

/' Convert a strings character set to another character set. '/
private function fb_hIntlConvertToWC( source as FBSTRING ptr, source_cp as UINT, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string tmp_str
	dim as long CharsRequired

	DBG_ASSERT( source <> NULL )
	DBG_ASSERT( result <> NULL )

	CharsRequired = MultiByteToWideChar( source_cp, 0, source->data, FB_STRSIZE(source), NULL, 0 )

	if ( fb_hStrAlloc( @tmp_str, (CharsRequired + 1) * sizeof(WCHAR) - 1 ) <> NULL ) then
		dim as ubyte ptr tmp_data = tmp_str.data
		dim as size_t idx = CharsRequired * sizeof(WCHAR)
		MultiByteToWideChar( source_cp, 0, cast(LPCSTR, source->data), FB_STRSIZE(source), cast(LPWSTR, tmp_data), CharsRequired )
		*(cast(WCHAR ptr, (tmp_data + idx))) = 0
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function

private function fb_hIntlConvertFromWC( source as FBSTRING ptr, dest_cp as UINT, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string tmp_str
	dim as long CharsRequired

	DBG_ASSERT( source <> NULL )
	DBG_ASSERT( result <> NULL )

	CharsRequired = WideCharToMultiByte( dest_cp, 0, cast(LPCWSTR, source->data), FB_STRSIZE(source) / sizeof(WCHAR), NULL, 0, NULL, NULL )

	if ( fb_hStrAlloc( @tmp_str, CharsRequired ) <> NULL ) then
		dim as ubyte ptr tmp_data = tmp_str.data
		WideCharToMultiByte( dest_cp, 0, cast(LPCWSTR, source->data), FB_STRSIZE(source) / sizeof(WCHAR), cast(LPSTR, tmp_data), CharsRequired, NULL, NULL )
		tmp_data[CharsRequired] = 0
	end if

	fb_StrSwapDesc( result, @tmp_str )
	return result
end function

extern "C"
function fb_hIntlConvertString( source as FBSTRING ptr, source_cp as long, dest_cp as long, result as FBSTRING ptr ) as FBSTRING ptr
	dim as destructable_string tmp_str
	fb_hIntlConvertToWC( source, source_cp, @tmp_str )
	return fb_hIntlConvertFromWC( @tmp_str , dest_cp, result )
end function

function fb_hGetLocaleInfo( Locale as LCID, _LCType as LCTYPE, pszBuffer as ubyte ptr, uiSize as size_t ) as ubyte ptr
	if ( uiSize = 0 ) then
		uiSize = 64
		pszBuffer = NULL
		do
			uiSize shl= 1
			pszBuffer = Reallocate( pszBuffer, uiSize )
			if ( pszBuffer = NULL ) then
				exit do
			end if
			if ( GetLocaleInfo( Locale, _LCType, pszBuffer, uiSize - 1 ) <> 0 ) then
				return pszBuffer
			end if
			if ( GetLastError( ) <> ERROR_INSUFFICIENT_BUFFER ) then
				DeAllocate( pszBuffer )
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