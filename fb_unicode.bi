/' Unicode definitions '/

extern "C"
type UTF_32 as ulong
type UTF_16 as ushort
type UTF_8 as ubyte

#define UTF8_BYTEMASK            &hBF
#define UTF8_BYTEMARK            &h80

#define UTF16_MAX_BMP            (cast(UTF_32,&h0000FFFF))
#define UTF16_SUR_HIGH_START     (cast(UTF_32,&hD800))
#define UTF16_SUR_HIGH_END       (cast(UTF_32,&hDBFF))
#define UTF16_SUR_LOW_START      (cast(UTF_32,&hDC00))
#define UTF16_SUR_LOW_END        (cast(UTF_32,&hDFFF))
#define UTF16_HALFSHIFT          10
#define UTF16_HALFBASE           (cast(UTF_32,&h0010000UL))
#define UTF16_HALFMASK           (cast(UTF_32,&h3FFUL))

#if defined (DISABLE_WCHAR)
	#define FB_WCHAR ubyte
	#define FB_WEOF (cast(FB_WCHAR, EOF))
	#define wcslen(s) strlen(s)
	#define _LC(c) c
	#define iswlower(c) islower(c)
	#define iswupper(c) isupper(c)
	#define towlower(c) tolower(c)
	#define towupper(c) toupper(c)
	#define wmemcmp(a,b,c) memcmp(a,b,c)
	#define wmemchr(a,b,c) memchr(a,b,c)
	#define mbstowcs __dos_mbstowcs
	#define wcstombs __dos_wcstombs
	#define wcsstr(str, strSearch) strstr(str, strSearch)
	#define wcsncmp(str1, str2, count) strncmp(str1, str2, count)
	#define wcstod   strtod
	#define wcstol   strtol
	#define wcstoll  strtoll
	#define wcstoul  strtoul
	#define wcstoull strtoull
	#define wcschr   strchr
	#define wcscspn  strcspn
		function __dos_mbstowcs(wcstr as FB_WCHAR ptr, mbstr as const ubyte ptr, count as ssize_t) as ssize_t
			memcpy(wcstr,mbstr,count)
			return count
		end function
		
		function __dos_wcstombs(mbstr as ubyte ptr, wcstr as const FB_WCHAR ptr, count as ssize_t) as ssize_t
			memcpy(mbstr,wcstr,count)
			return count
		end function
		
		function swprintf(buffer as FB_WCHAR ptr, n as ssize_t, _format as const FB_WCHAR ptr, ...) as long
			dim result as long
			dim ap as va_list
			va_start(ap, _format)
			result = vsprintf( buffer, _format, ap )
			va_end(ap)
			return result
		end function
#elseif defined (HOST_WIN32)
	#define FB_WCHAR ushort
	#define _LC(c) wstr(c)
	#define FB_WEOF (cast(FB_WCHAR,-1))
	#define FB_WSTR_FROM_INT( buffer, num )        _itow( num, buffer, 10 )
	#define FB_WSTR_FROM_UINT( buffer, num )       _ultow( cast(ulong, num), buffer, 10 )
	#define FB_WSTR_FROM_UINT_OCT( buffer, num )   _itow( num, buffer, 8 )
	#define FB_WSTR_FROM_INT64( buffer, num )      _i64tow( num, buffer, 10 )
	#define FB_WSTR_FROM_UINT64( buffer, num )     _ui64tow( num, buffer, 10 )
	#define FB_WSTR_FROM_UINT64_OCT( buffer, num ) _ui64tow( num, buffer, 8 )
#else
	#define __USE_ISOC99 1
	#define __USE_ISOC95 1
	#include "crt/wchar.bi"
	'#include "crt/wctype.bi"
	#include "crt_extra/wctype.bi"
	#define FB_WCHAR wchar_t
	#define FB_WEOF cast(FB_WCHAR, WEOF)
	#define _LC(c) wstr(c)
#endif

#ifdef HOST_ANDROID
#ifndef DISABLE_WCHAR
/' If you want to target Android 5.0+ (or 2.3+ and don't care that half the wstring functions are
'' broken you can use this '/

/' Note: old NDKs defined wchar_t as 8 bit in APIs before 9 (Android 2.3), and 32 bit in API 9 and later,
'' but now NDKs define it as 32 bit everywhere. https://code.google.com/p/android/issues/detail?id=57267 '/
#ifndef wcstoull
	/' Not added until Android 5.0 '/
	#define wcstoull wcstoul
#endif
/' Early NDKs (before Android 2.3?) declared mbstowcs and wcstombs in <stdlib.h>, but didn't actually provide an
'' implementation in libc; however all Android versions have mbsrtowcs and wcsrtombs. '/
	#define mbstowcs __android_mbstowcs
	#define wcstombs __android_wcstombs
	function __android_mbstowcs(byval dst as FB_WCHAR ptr, byval src as ubyte ptr, byval count as size_t) as size_t
		return mbsrtowcs(dst, @src, count, NULL)
	end function
	function __android_wcstombs(byval dst as ubyte ptr, byval src as const FB_WCHAR ptr, byva count as size_t) as size_t
		return wcsrtombs(dst, @src, count, NULL)
	end function
#endif
#endif


#ifndef FB_WSTR_FROM_INT
#define FB_WSTR_FROM_INT( buffer, num ) swprintf( buffer, sizeof( long ) * 3 + 1, @wstr("%d"), cast(long, num) )
#endif

#ifndef FB_WSTR_FROM_UINT
#define FB_WSTR_FROM_UINT( buffer, num ) swprintf( buffer, sizeof( ulong ) * 3 + 1, @wstr("%u"), cast(ulong, num) )
#endif

#ifndef FB_WSTR_FROM_UINT_OCT
#define FB_WSTR_FROM_UINT_OCT( buffer, num ) swprintf( buffer, sizeof( long ) * 4 + 1, @wstr("%o"), cast(ulong, num) )
#endif

#ifndef FB_WSTR_FROM_INT64
#define FB_WSTR_FROM_INT64( buffer, num ) swprintf( buffer, sizeof( longint ) * 3 + 1, @wstr("%lld"), cast(longint, num) )
#endif

#ifndef FB_WSTR_FROM_UINT64
#define FB_WSTR_FROM_UINT64( buffer, num ) swprintf( buffer, sizeof( ulongint ) * 3 + 1, @wstr("%llu"), cast(ulongint, num) )
#endif

#ifndef FB_WSTR_FROM_UINT64_OCT
#define FB_WSTR_FROM_UINT64_OCT( buffer, num ) swprintf( buffer, sizeof( longint ) * 4 + 1, @wstr("%llo"), cast(ulongint, num) )
#endif

#ifndef FB_WSTR_FROM_FLOAT
#define FB_WSTR_FROM_FLOAT( buffer, num ) swprintf( buffer, 7+8 + 1, @wstr("%.7g"), cast(double, num) )
#endif

#ifndef FB_WSTR_FROM_DOUBLE
#define FB_WSTR_FROM_DOUBLE( buffer, num ) swprintf( buffer, 16+8 + 1, @wstr("%.16g"), cast(double, num) )
#endif

/' Calculate the number of characters between two pointers. '/
private function fb_wstr_CalcDiff( ini as const FB_WCHAR ptr, _end as const FB_WCHAR ptr ) as ssize_t
	return (cast(ssize_t, _end) - cast(ssize_t, ini)) / sizeof( FB_WCHAR )
end function

private function fb_wstr_AllocTemp( chars as ssize_t ) as FB_WCHAR ptr
	/' plus the null-term '/
	return cast(FB_WCHAR ptr, malloc( (chars + 1) * sizeof( FB_WCHAR ) ) )
end function

private sub fb_wstr_Del( s as FB_WCHAR ptr)
	free ( cast(any ptr, s) )
end sub

/' Return the length of a WSTRING. '/
private function fb_wstr_Len( s as const FB_WCHAR ptr ) as ssize_t
	/' without the null-term '/
	return wcslen( s )
end function

declare function fb_wstr_ConvFromA( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as const ubyte ptr ) as ssize_t
declare function fb_wstr_ConvToA( dst as ubyte ptr, dst_chars as ssize_t, src as const FB_WCHAR ptr ) as ssize_t

private function fb_wstr_IsLower( c as FB_WCHAR ) as long
	return iswlower( c )
end function

private function fb_wstr_IsUpper( c as FB_WCHAR ) as long
	return iswupper( c )
end function

private function fb_wstr_ToLower( c as FB_WCHAR ) as FB_WCHAR
	return towlower( c )
end function

private function fb_wstr_ToUpper( c as FB_WCHAR ) as FB_WCHAR
	return towupper( c )
end function

/' Copy n characters from A to B and terminate with NUL. '/
private sub fb_wstr_Copy( dst as FB_WCHAR ptr, src as const FB_WCHAR ptr, chars as ssize_t )
	if( (src <> NULL) andalso (chars > 0) ) then
		dst = cast(FB_WCHAR ptr, FB_MEMCPYX( dst, src, chars * sizeof( FB_WCHAR ) ))
	end if
	/' add the null-term '/
	*dst = asc(!"\000") '' NUL CHAR
end sub

/' Copy n characters from A to B. '/
private function fb_wstr_Move( dst as FB_WCHAR ptr, src as const FB_WCHAR ptr, chars as ssize_t ) as FB_WCHAR ptr
	return cast(FB_WCHAR ptr, FB_MEMCPYX( dst, src, chars * sizeof( FB_WCHAR ) ))
end function

private sub fb_wstr_Fill( dst as FB_WCHAR ptr, c as FB_WCHAR, chars as ssize_t )
	dim i as long = 0
	while( i < chars )
		*dst = c
		dst += 1
		i += 1
	wend
	/' add null-term '/
	*dst = asc(!"\000") '' NUL CHAR
end sub

/' Skip all characters (c) from the beginning of the string, max 'n' chars. '/
private function fb_wstr_SkipChar( s as const FB_WCHAR ptr, chars as ssize_t, c as FB_WCHAR ) as const FB_WCHAR ptr
	if( s = NULL ) then
		return NULL
	end if
	
	dim p as const FB_WCHAR ptr = s
	
	while( chars > 0 )
		if( *p <> c ) then
			return p
		end if
		p += 1
		chars -= 1
	wend

	return p
end function

/' Skip all characters (c) from the end of the string, max 'n' chars. '/
private function fb_wstr_SkipCharRev( s as const FB_WCHAR ptr, chars as ssize_t, c as FB_WCHAR ) as const FB_WCHAR ptr
	if( (s = NULL) orelse (chars <= 0) ) then
		return s
	end if

	/' fixed-len's are filled with null's as in PB, strip them too '/
	dim p as const FB_WCHAR ptr = @s[chars]
	while( chars > 0 )
		p -= 1
		if( *p <> c ) then
			return p+1
		end if
		chars -= 1
	wend
	return p
end function

private function fb_wstr_Instr( s as const FB_WCHAR ptr, patt as const FB_WCHAR ptr ) as FB_WCHAR ptr
	return wcsstr( s, patt )
end function

private function fb_wstr_InstrAny( s as const FB_WCHAR ptr, sset as const FB_WCHAR ptr ) as size_t
	return wcscspn( s, sset )
end function

private function fb_wstr_Compare( str1 as const FB_WCHAR ptr, str2 as const FB_WCHAR ptr, chars as ssize_t ) as long
	return wcsncmp( str1, str2, chars )
end function
end extern
