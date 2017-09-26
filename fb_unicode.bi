/' Unicode definitions '/

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

#if defined (HOST_DOS)
	#define FB_WCHAR ubyte
	#define _LC(c) c
	#define FB_WEOF ((FB_WCHAR)EOF)
	#define wcslen(s) strlen(s)
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
		function __dos_mbstowcs(wcstr as FB_WCHAR ptr, mbstr as ubyte const ptr, count as ssize_t) as ssize_t
			memcpy(wcstr,mbstr,count)
			return count
		end function
		
		function __dos_wcstombs(mbstr as ubyte ptr, wcstr as FB_WCHAR conts ptr, count as ssize_t) as ssize_t
			memcpy(mbstr,wcstr,count)
			return count
		end function
		
		function swprintf(buffer as FB_WCHAR ptr, n as ssize_t, _format as FB_WCHAR conts ptr, ...) as integer
			dim result as long
			dim ap as va_list
			va_start(ap, _format)
			result = vsprintf( buffer, _format, ap )
			va_end(ap)
			return result
		end function
#elseif defined (HOST_WIN32)
	#define FB_WCHAR ushort
	/'#define _LC(c) !##c'/
	/'#if defined (HOST_MINGW)
		#define FB_WEOF (cast(FB_WCHAR,WEOF))
		#define swprintf _snwprintf
		#define FB_WSTR_FROM_INT( buffer, num )        _itow( num, buffer, 10 )
		#define FB_WSTR_FROM_UINT( buffer, num )       _ultow( cast(ulong, num), buffer, 10 )
		#define FB_WSTR_FROM_UINT_OCT( buffer, num )   _itow( num, buffer, 8 )
		#define FB_WSTR_FROM_INT64( buffer, num )      _i64tow( num, buffer, 10 )
		#define FB_WSTR_FROM_UINT64( buffer, num )     _ui64tow( num, buffer, 10 )
		#define FB_WSTR_FROM_UINT64_OCT( buffer, num ) _ui64tow( num, buffer, 8 )
	#else'/
		#define FB_WEOF (cast(FB_WCHAR,-1))
	/'#endif'/
#else
	#define __USE_ISOC99 1
	#define __USE_ISOC95 1
	#define FB_WCHAR wchar_t '?
	/'#define _LC(c) !##c'/
	#define FB_WEOF ((FB_WCHAR)WEOF)
#endif

#ifndef FB_WSTR_FROM_INT
#define FB_WSTR_FROM_INT( buffer, num ) swprintf( buffer, sizeof( int ) * 3 + 1, _LC("%d"), cast(long, num) )
#endif

#ifndef FB_WSTR_FROM_UINT
#define FB_WSTR_FROM_UINT( buffer, num ) swprintf( buffer, sizeof( unsigned int ) * 3 + 1, _LC("%u"), cast(ulong, num) )
#endif

#ifndef FB_WSTR_FROM_UINT_OCT
#define FB_WSTR_FROM_UINT_OCT( buffer, num ) swprintf( buffer, sizeof( int ) * 4 + 1, _LC("%o"), cast(ulong, num) )
#endif

#ifndef FB_WSTR_FROM_INT64
#define FB_WSTR_FROM_INT64( buffer, num ) swprintf( buffer, sizeof( long long ) * 3 + 1, _LC("%lld"), cast(longint, num) )
#endif

#ifndef FB_WSTR_FROM_UINT64
#define FB_WSTR_FROM_UINT64( buffer, num ) swprintf( buffer, sizeof( unsigned long long ) * 3 + 1, _LC("%llu"), cast(ulongint, num) )
#endif

#ifndef FB_WSTR_FROM_UINT64_OCT
#define FB_WSTR_FROM_UINT64_OCT( buffer, num ) swprintf( buffer, sizeof( long long ) * 4 + 1, _LC("%llo"), cast(ulongint, num) )
#endif

#ifndef FB_WSTR_FROM_FLOAT
#define FB_WSTR_FROM_FLOAT( buffer, num ) swprintf( buffer, 7+8 + 1, _LC("%.7g"), cast(double, num) )
#endif

#ifndef FB_WSTR_FROM_DOUBLE
#define FB_WSTR_FROM_DOUBLE( buffer, num ) swprintf( buffer, 16+8 + 1, _LC("%.16g"), cast(double, num) )
#endif

/' Calculate the number of characters between two pointers. '/
function fb_wstr_CalcDiff( ini as FB_WCHAR const ptr, _end as FB_WCHAR const ptr ) as ssize_t
	return (cast(ulong, _end) - cast(ulong, ini)) / sizeof( FB_WCHAR )
end function

function fb_wstr_AllocTemp( chars as ssize_t ) as FB_WCHAR ptr
	/' plus the null-term '/
	return cast(FB_WCHAR ptr, malloc( (chars + 1) * sizeof( FB_WCHAR ) ) )
end function

sub fb_wstr_Del( s as FB_WCHAR ptr)
	free ( cast(any ptr, s) )
end sub

/' Return the length of a WSTRING. '/
function fb_wstr_Len( s as FB_WCHAR const ptr ) as ssize_t
	/' without the null-term '/
	return wcslen( s )
end function

declare function fb_wstr_ConvFromA( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as ubyte const ptr ) as ssize_t
declare function fb_wstr_ConvToA( dst as ubyte ptr, dst_chars as ssize_t, src as FB_WCHAR const ptr ) as ssize_t

function fb_wstr_IsLower( c as FB_WCHAR ) as integer
	return iswlower( c )
end function

function fb_wstr_IsUpper( c as FB_WCHAR ) as integer
	return iswupper( c )
end function

function fb_wstr_ToLower( c as FB_WCHAR ) as FB_WCHAR
	return towlower( c )
end function

function fb_wstr_ToUpper( c as FB_WCHAR ) as FB_WCHAR
	return towupper( c )
end function

/' Copy n characters from A to B and terminate with NUL. '/
sub fb_wstr_Copy( dst as FB_WCHAR ptr, src as FB_WCHAR const ptr, chars as ssize_t )
	if( (src <> NULL) and (chars > 0) ) then
		dst = cast(FB_WCHAR ptr, FB_MEMCPYX( dst, src, chars * sizeof( FB_WCHAR ) ))
	end if
	/' add the null-term '/
	dst[chars + 1] = 0
end sub

/' Copy n characters from A to B. '/
function fb_wstr_Move( dst as FB_WCHAR ptr, src as FB_WCHAR const ptr, chars as ssize_t ) as FB_WCHAR ptr
	return cast(FB_WCHAR ptr, FB_MEMCPYX( dst, src, chars * sizeof( FB_WCHAR ) ))
end function

sub fb_wstr_Fill( dst as FB_WCHAR ptr, c as FB_WCHAR, chars as ssize_t )
	dim i as long
	for i = 0 to chars
		dst[i] = c
	next
	/' add null-term '/
	dst[i] = 0
end sub

/' Skip all characters (c) from the beginning of the string, max 'n' chars. '/
function fb_wstr_SkipChar( s as FB_WCHAR const ptr, chars as ssize_t, c as FB_WCHAR ) as FB_WCHAR const ptr
	if( s = NULL ) then
		return NULL
	end if
	
	dim p as FB_WCHAR ptr = s
	
	while( chars > 0 )
		if( p <> c ) then
			return p
		end if
		p += 1
		chars -= 1
	wend

	return p
end function

/' Skip all characters (c) from the end of the string, max 'n' chars. '/
function fb_wstr_SkipCharRev( s as FB_WCHAR const ptr, chars as ssize_t, c as FB_WCHAR) as FB_WCHAR const ptr
	if( (s = NULL) or (chars <= 0) ) then
		return s
	end if

	/' fixed-len's are filled with null's as in PB, strip them too '/
	dim p as FB_WCHAR ptr = @s[chars-1]
	while( chars > 0 )
		if( *p <> c ) then
			return p
		end if
		p -= 1
		chars -= 1
	wend
	return p
end function

function fb_wstr_Instr( s as FB_WCHAR const ptr, patt as FB_WCHAR const ptr ) as FB_WCHAR ptr
	return wcsstr( s, patt )
end function

function fb_wstr_InstrAny( s as FB_WCHAR const ptr, sset as FB_WCHAR const ptr ) as size_t
	return wcscspn( s, sset )
end function

function fb_wstr_Compare( str1 as FB_WCHAR const ptr, str2 as FB_WCHAR const ptr, chars as ssize_t ) as integer
	return wcsncmp( str1, str2, chars )
end function
