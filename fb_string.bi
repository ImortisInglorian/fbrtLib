/' strings '/

'These undefs will not be needed once this replaces the current RTLIB
#ifdef fb_hStrDelTemp
	#undef fb_hStrDelTemp
	#undef fb_StrInit 
	#undef fb_StrAssign
	#undef fb_StrDelete
	#undef fb_StrConcat
	#undef fb_StrConcatAssign
	#undef fb_StrConcatByref
	#undef fb_StrCompare
	#undef fb_StrAllocTempResult
	#undef fb_StrAllocTempDescF
	#undef fb_StrAllocTempDescZEx 
	#undef fb_StrAllocTempDescZ
	#undef fb_StrLen
	#undef fb_BoolToStr
	#undef fb_IntToStr
	#undef fb_UIntToStr
	#undef fb_LongintToStr
	#undef fb_ULongintToStr
	#undef fb_FloatToStr
	#undef fb_DoubleToStr
	#undef fb_CHR
	#undef fb_ASC
	#undef fb_CVD
	#undef fb_CVS
	#undef fb_CVSHORT
	#undef fb_CVL
	#undef fb_CVLONGINT
	#undef fb_MKD
	#undef fb_MKS
	#undef fb_MKSHORT
	#undef fb_MKI
	#undef fb_MKL
	#undef fb_MKLONGINT
	#undef fb_LTRIM
	#undef fb_LTrimEx
	#undef fb_LTrimAny
	#undef fb_RTRIM
	#undef fb_RTrimEx
	#undef fb_RTrimAny
	#undef fb_TRIM
	#undef fb_TrimEx
	#undef fb_TrimAny
	#undef fb_StrLset
	#undef fb_StrLsetANA
	#undef fb_StrRset
	#undef fb_StrRsetANA
	#undef fb_StrLcase2
	#undef fb_StrUcase2
	#undef fb_StrFill1
	#undef fb_StrFill2
	#undef fb_StrInstr
	#undef fb_StrInstrAny
	#undef fb_StrInstrRev
	#undef fb_StrInstrRevAny
	#undef fb_StrMid
	#undef fb_StrAssignMid
	#undef fb_WstrAlloc
	#undef fb_WstrAssignToA_Init
	#undef fb_WstrDelete
	#undef fb_WstrAssign
	#undef fb_WstrAssignFromA
	#undef fb_WstrAssignToA
	#undef fb_WstrConcat
	#undef fb_WstrConcatWA
	#undef fb_WstrConcatAW
	#undef fb_WstrConcatAssign
	#undef fb_WstrLen
	#undef fb_WstrCompare
	#undef fb_BoolToWstr
	#undef fb_IntToWstr
	#undef fb_UIntToWstr
	#undef fb_LongintToWstr
	#undef fb_ULongintToWstr
	#undef fb_FloatToWstr
	#undef fb_FloatExToWstr
	#undef fb_DoubleToWstr
	#undef fb_StrToWstr
	#undef fb_WstrAsc
	#undef fb_WstrLTrim
	#undef fb_WstrLTrimEx
	#undef fb_WstrLTrimAny
	#undef fb_WstrRTrim
	#undef fb_WstrRTrimEx
	#undef fb_WstrRTrimAny
	#undef fb_WstrToStr
	#undef fb_WstrChr
	#undef fb_WstrTrimEx
	#undef fb_WstrTrimAny
	#undef fb_WstrLset
	#undef fb_WstrRset
	#undef fb_WstrLcase2
	#undef fb_WstrUcase2
	#undef fb_WstrFill1
	#undef fb_WstrTrim
	#undef fb_WstrFill2
	#undef fb_WstrInstr
	#undef fb_WstrInstrAny
	#undef fb_WstrInstrRev
	#undef fb_WstrInstrRevAny
	#undef fb_WstrMid
	#undef fb_WstrAssignMid
#endif

extern "C"

/' Flag to identify a string as a temporary string.
 *
 * This flag is stored in struct _FBSTRING::len so it's absolutely required
 * to use FB_STRSIZE(s) to query a strings length.
 '/
#ifdef HOST_64BIT
	#define FB_TEMPSTRBIT (cast(longint, &h8000000000000000ll))
#else
	#define FB_TEMPSTRBIT (cast(long, &h80000000))
#endif

/' Flag to identify a string size as fixed length without a null terminator
 *
 * This flag is stored in in the ssize_t size parameter passed in to string 
 * handling functions, use FB_STRSETUP_FIX)() and FB_STRSETUP_DYN() to query
 * the string's length.
 '/
#ifdef HOST_64BIT
	#define FB_STRISFIXED (cast(longint, &h8000000000000000ll))
	#define FB_STRSIZEMSK (cast(longint, &h7fffffffffffffffll))
#else
	#define FB_STRISFIXED (cast(long, &h80000000))
	#define FB_STRSIZEMSK (cast(long, &h7fffffff))
#endif

'' Value to identify string size as variable length
#define FB_STRSIZEVARLEN -1

/' Returns if the string is a temporary string.
 '/
#define FB_ISTEMP(s) ((cast(FBSTRING ptr, s)->len and FB_TEMPSTRBIT) <> 0)

/' Returns a string length.
 '/
#define FB_STRSIZE(s) (Cast(ssize_t, (cast(FBSTRING ptr, s)->len and not(FB_TEMPSTRBIT))))

/' Returns the string data.
 '/
#define FB_STRPTR(s,size) ( iif(s = NULL, NULL , ( iif(size = -1, (Cast(FBSTRING ptr, s)->data,  cast(ubyte ptr,s ) )))))

#macro FB_STRSETUP_FIX(s,size,_ptr,_len)
	if( s = NULL ) then
		_ptr = NULL
		_len = 0
	else
		if( size = FB_STRSIZEVARLEN ) then
			/' var-len STRING, descriptor '/
			_ptr = cast(FBSTRING ptr, s)->data
			_len = FB_STRSIZE( s )
		elseif( size and FB_STRISFIXED ) then
			/' fix-len STRING*N '/
			_ptr = cast(ubyte ptr, s)
			_len = size and FB_STRSIZEMSK
		elseif( size = 0 ) then
			/' ZSTRING PTR, unknown length '/
			_ptr = cast(ubyte ptr, s)
			_len = strlen( _ptr )
		else
			/' fix-len ZSTRING*N '/
			_ptr = cast(ubyte ptr, s)
			_len = strlen( cast(ubyte ptr, s) )
		end if
	end if
#endmacro

#macro FB_STRSETUP_DYN(s,size,_ptr,_len)
	if( s = NULL ) then
		_ptr = NULL
		_len = 0
	else
		if( size = FB_STRSIZEVARLEN ) then
			/' var-len STRING, descriptor '/
			_ptr = cast(FBSTRING ptr, s)->data
			_len = FB_STRSIZE( s )
		elseif( size and FB_STRISFIXED ) then
			/' fix-len STRING*N '/
			_ptr = cast(ubyte ptr, s)
			_len = size and FB_STRSIZEMSK
		elseif( size = 0 ) then
			/' ZSTRING PTR, unknown length '/
			_ptr = cast(ubyte ptr, s)
			_len = strlen( _ptr )
		else
			/' fix-len ZSTRING*N '/
			_ptr = cast(ubyte ptr, s)
			/' without terminating NUL '/
			_len = size - 1
			end if
		end if
#endmacro

/' Structure containing information about a specific string.
 *
 * This structure hols all informations about a specific string. This is
 * required to allow BASIC-style strings that may contain NUL characters.
 '/
type FBSTRING
	as ubyte ptr data    /'< pointer to the real string data '/
	as ssize_t len     /'< String length. '/
	as ssize_t size    /'< Size of allocated memory block. '/
end type


type FB_STR_TMPDESC
	as FB_LISTELEM     elem
	as FBSTRING        desc
end type


/' protos '/

/' Sets the length of a string (without reallocation).
 *
 * This function preserves any flags set for this string descriptor.
 '/



private sub fb_hStrSetLength( _str as FBSTRING ptr, size as size_t )
	_str->len = size or (_str->len and FB_TEMPSTRBIT)
end sub

declare function fb_hStrAllocTempDesc		FBCALL ( ) as FBSTRING ptr
declare function fb_hStrDelTempDesc 		FBCALL ( str as FBSTRING ptr ) as long
declare function fb_hStrAlloc 				FBCALL ( str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrRealloc 			FBCALL ( str as FBSTRING ptr, size as ssize_t, _preserve as long ) as FBSTRING ptr
declare function fb_hStrAllocTemp 			FBCALL ( str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrAllocTemp_NoLock 	FBCALL ( str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrDelTemp 			FBCALL ( str as FBSTRING ptr ) as long
declare function fb_hStrDelTemp_NoLock  	FBCALL ( str as FBSTRING ptr ) as long
declare sub      fb_hStrCopy                FBCALL ( dst as ubyte ptr, src as const ubyte ptr , bytes as ssize_t )
declare sub      fb_hStrCopyN               FBCALL ( dst as ubyte ptr, src as const ubyte ptr , bytes as ssize_t )
declare function fb_hStrSkipChar 			FBCALL ( s as ubyte ptr, len as ssize_t, c as long ) as ubyte ptr
declare function fb_hStrSkipCharRev 		FBCALL ( s as ubyte ptr, len as ssize_t, c as long ) as ubyte ptr


/' public '/

declare function fb_StrInit 				FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as long ) as any ptr
declare function fb_StrAssign				FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as long ) as any ptr
declare function fb_StrAssignEx 			FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as long, is_init as long )as any ptr
declare sub 	 fb_StrDelete 				FBCALL ( str as FBSTRING ptr )
declare function fb_StrConcat 				FBCALL ( dst as FBSTRING ptr, str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as FBSTRING ptr
declare function fb_StrConcatAssign 		FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as long ) as any ptr
declare function fb_StrConcatByref			FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as long ) as any ptr
declare function fb_StrCompare 				FBCALL ( str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as long
declare function fb_StrAllocTempResult 		FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrAllocTempDescF		FBCALL ( str as ubyte ptr, str_size as ssize_t ) as FBSTRING ptr
declare function fb_StrAllocTempDescV		FBCALL ( str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrAllocTempDescZEx 	FBCALL ( str as const ubyte ptr, len as ssize_t ) as FBSTRING ptr
declare function fb_StrAllocTempDescZ 		FBCALL ( str as const ubyte ptr ) as FBSTRING ptr
declare function fb_StrLen 					FBCALL ( str as any ptr, str_size as ssize_t ) as ssize_t

declare function fb_hBoolToStr 				FBCALL ( num as ubyte ) as ubyte ptr
declare function fb_BoolToStr 				FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_IntToStr 				FBCALL ( num as long ) as FBSTRING ptr
declare function fb_IntToStrQB 				FBCALL ( num as long ) as FBSTRING ptr
declare function fb_UIntToStr 				FBCALL ( num as ulong ) as FBSTRING ptr
declare function fb_UIntToStrQB 			FBCALL ( num as ulong ) as FBSTRING ptr
declare function fb_LongintToStr 			FBCALL ( num as longint ) as FBSTRING ptr
declare function fb_LongintToStrQB 			FBCALL ( num as longint ) as FBSTRING ptr
declare function fb_ULongintToStr 			FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_ULongintToStrQB 		FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_FloatToStr 				FBCALL ( num as single ) as FBSTRING ptr
declare function fb_FloatToStrQB 			FBCALL ( num as single ) as FBSTRING ptr
declare function fb_DoubleToStr 			FBCALL ( num as double ) as FBSTRING ptr
declare function fb_DoubleToStrQB 			FBCALL ( num as double ) as FBSTRING ptr

#define FB_F2A_ADDBLANK     &h00000001

declare function fb_hStr2Bool 				FBCALL ( src as ubyte ptr, len as ssize_t ) as ubyte
declare function fb_hStr2Double 			FBCALL ( src as ubyte ptr, len as ssize_t ) as double
declare function fb_hStr2Int 				FBCALL ( src as ubyte ptr, len as ssize_t ) as long
declare function fb_hStr2UInt 				FBCALL ( src as ubyte ptr, len as ssize_t ) as ulong
declare function fb_hStr2Longint 			FBCALL ( src as ubyte ptr, len as ssize_t ) as longint
declare function fb_hStr2ULongint 			FBCALL ( src as ubyte ptr, len as ssize_t ) as ulongint
declare function fb_hStrRadix2Int 			FBCALL ( src as ubyte ptr, len as ssize_t, radix as long ) as long
declare function fb_hStrRadix2Longint 		FBCALL ( s as ubyte ptr, len as ssize_t, radix as long ) as longint
declare function fb_hFloat2Str       		cdecl	( val as double, buffer as ubyte ptr, digits as long, mask as long ) as ubyte ptr

declare function fb_CHR              		cdecl	( args as long, ... ) as FBSTRING ptr
declare function fb_ASC 					FBCALL ( str as FBSTRING ptr, _pos as ssize_t ) as ulong
declare function fb_VAL 					FBCALL ( str as FBSTRING ptr ) as double
declare function fb_CVD 					FBCALL ( str as FBSTRING ptr ) as double
declare function fb_CVS 					FBCALL ( str as FBSTRING ptr ) as single
declare function fb_CVSHORT 				FBCALL ( str as FBSTRING ptr ) as short
declare function fb_CVI 					FBCALL ( str as FBSTRING ptr ) as long /' 32bit legacy '/
declare function fb_CVL 					FBCALL ( str as FBSTRING ptr ) as long
declare function fb_CVLONGINT 				FBCALL ( str as FBSTRING ptr ) as longint
declare function fb_HEX 					FBCALL ( num as long ) as FBSTRING ptr
declare function fb_OCT 					FBCALL ( num as long) as FBSTRING ptr
declare function fb_BIN 					FBCALL ( num as long ) as FBSTRING ptr

declare function fb_BIN_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_BIN_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_BIN_i 					FBCALL ( num as ulong ) as FBSTRING ptr
declare function fb_BIN_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_BIN_p 					FBCALL ( p as const any ptr ) as FBSTRING ptr
declare function fb_BINEx_b 				FBCALL ( num as ubyte, digits as long ) as FBSTRING ptr
declare function fb_BINEx_s 				FBCALL ( num as ushort, digits as long ) as FBSTRING ptr
declare function fb_BINEx_i 				FBCALL ( num as ulong, digits as long ) as FBSTRING ptr
declare function fb_BINEx_l 				FBCALL ( num as ulongint, digits as long ) as FBSTRING ptr
declare function fb_BINEx_p 				FBCALL ( p as const any ptr, digits as long ) as FBSTRING ptr

declare function fb_OCT_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_OCT_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_OCT_i 					FBCALL ( num as ulong ) as FBSTRING ptr
declare function fb_OCT_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_OCT_p 					FBCALL ( p as const any ptr ) as FBSTRING ptr
declare function fb_OCTEx_b 				FBCALL ( num as ubyte, digits as long ) as FBSTRING ptr
declare function fb_OCTEx_s 				FBCALL ( num as ushort, digits as long ) as FBSTRING ptr
declare function fb_OCTEx_i 				FBCALL ( num as ulong, digits as long ) as FBSTRING ptr
declare function fb_OCTEx_l 				FBCALL ( num as ulongint, digits as long ) as FBSTRING ptr
declare function fb_OCTEx_p 				FBCALL ( p as const any ptr, digits as long ) as FBSTRING ptr

declare function fb_HEX_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_HEX_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_HEX_i 					FBCALL ( num as ulong ) as FBSTRING ptr
declare function fb_HEX_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_HEX_p 					FBCALL ( p as const any ptr ) as FBSTRING ptr
declare function fb_HEXEx_b 				FBCALL ( num as ubyte, digits as long ) as FBSTRING ptr
declare function fb_HEXEx_s 				FBCALL ( num as ushort, digits as long ) as FBSTRING ptr
declare function fb_HEXEx_i 				FBCALL ( num as ulong, digits as long ) as FBSTRING ptr
declare function fb_HEXEx_l 				FBCALL ( num as ulongint, digits as long ) as FBSTRING ptr
declare function fb_HEXEx_p 				FBCALL ( p as const any ptr, digits as long ) as FBSTRING ptr

declare function fb_WstrBin_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrBin_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrBin_i 				FBCALL ( num as ulong ) as FB_WCHAR ptr
declare function fb_WstrBin_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrBin_p 				FBCALL ( p as const any ptr ) as FB_WCHAR ptr
declare function fb_WstrBinEx_b 			FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
declare function fb_WstrBinEx_s 			FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
declare function fb_WstrBinEx_i 			FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
declare function fb_WstrBinEx_l 			FBCALL ( num as ulongint, digits as long ) as FB_WCHAR ptr
declare function fb_WstrBinEx_p 			FBCALL ( p as const any ptr, digits as long ) as FB_WCHAR ptr

declare function fb_WstrHex_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrHex_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrHex_i 				FBCALL ( num as ulong ) as FB_WCHAR ptr
declare function fb_WstrHex_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrHex_p 				FBCALL ( p as const any ptr ) as FB_WCHAR ptr
declare function fb_WstrHexEx_b 			FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
declare function fb_WstrHexEx_s 			FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
declare function fb_WstrHexEx_i 			FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
declare function fb_WstrHexEx_l 			FBCALL ( num as ulongint, digits as long ) as FB_WCHAR ptr
declare function fb_WstrHexEx_p 			FBCALL ( p as const any ptr, digits as long ) as FB_WCHAR ptr

declare function fb_WstrOct_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrOct_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrOct_i 				FBCALL ( num as ulong ) as FB_WCHAR ptr
declare function fb_WstrOct_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrOct_p 				FBCALL ( p as const any ptr ) as FB_WCHAR ptr
declare function fb_WstrOctEx_b 			FBCALL ( num as ubyte, digits as long ) as FB_WCHAR ptr
declare function fb_WstrOctEx_s 			FBCALL ( num as ushort, digits as long ) as FB_WCHAR ptr
declare function fb_WstrOctEx_i 			FBCALL ( num as ulong, digits as long ) as FB_WCHAR ptr
declare function fb_WstrOctEx_l 			FBCALL ( num as ulongint, digits as long ) as FB_WCHAR ptr
declare function fb_WstrOctEx_p 			FBCALL ( p as const any ptr, digits as long ) as FB_WCHAR ptr

declare function fb_MKD 					FBCALL ( num as double ) as FBSTRING ptr
declare function fb_MKS 					FBCALL ( num as single ) as FBSTRING ptr
declare function fb_MKSHORT 				FBCALL ( num as short ) as FBSTRING ptr
declare function fb_MKI 					FBCALL ( num as ssize_t ) as FBSTRING ptr
declare function fb_MKL 					FBCALL ( num as long ) as FBSTRING ptr
declare function fb_MKLONGINT 				FBCALL ( num as longint ) as FBSTRING ptr
declare function fb_LEFT 					FBCALL ( str as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
declare function fb_RIGHT 					FBCALL ( str as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
declare function fb_SPACE 					FBCALL ( chars as ssize_t ) as FBSTRING ptr
declare function fb_LTRIM 					FBCALL ( str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_LTrimEx 				FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_LTrimAny 				FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTRIM 					FBCALL ( str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTrimEx 				FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTrimAny 				FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TRIM 					FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TrimEx 					FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TrimAny 				FBCALL ( str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare sub 	 fb_StrLset 				FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
declare sub 	 fb_StrLsetANA 				FBCALL ( dst as any ptr, dst_size as ssize_t, src as FBSTRING ptr )
declare sub 	 fb_StrRset 				FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
declare sub 	 fb_StrRsetANA 				FBCALL ( dst as any ptr, dst_size as ssize_t, src as FBSTRING ptr )
declare function fb_StrLcase2 				FBCALL ( src as FBSTRING ptr, mode as long ) as FBSTRING ptr
declare function fb_StrUcase2 				FBCALL ( src as FBSTRING ptr, mode as long ) as FBSTRING ptr
declare function fb_StrFill1 				FBCALL ( cnt as ssize_t, fchar as long ) as FBSTRING ptr
declare function fb_StrFill2 				FBCALL ( cnt as ssize_t, src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrInstr 				FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
declare function fb_StrInstrAny 			FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
declare function fb_StrInstrRev 			FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
declare function fb_StrInstrRevAny 			FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
declare function fb_StrMid 					FBCALL ( src as FBSTRING ptr, start as ssize_t, len as ssize_t ) as FBSTRING ptr
declare sub 	 fb_StrAssignMid 			FBCALL ( dst as FBSTRING ptr, start as ssize_t, len as ssize_t, src as FBSTRING ptr )

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * Unicode strings
 *************************************************************************************************'/

declare function fb_WstrAlloc 				FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrAssignToA_Init 		FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long ) as any ptr
declare sub 	 fb_WstrDelete 				FBCALL ( str as FB_WCHAR ptr )
declare function fb_WstrAssign 				FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrAssignFromA 		FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as any ptr, src_chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrAssignToA 			FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long ) as any ptr
declare function fb_WstrAssignToAEx 		FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as long, is_init as long ) as any ptr
declare function fb_WstrConcat 				FBCALL ( str1 as const FB_WCHAR ptr, str2 as const FB_WCHAR ptr )  as FB_WCHAR ptr
declare function fb_WstrConcatWA 			FBCALL ( str1 as const FB_WCHAR ptr, str2 as const any ptr, str2_size as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrConcatAW 			FBCALL ( str1 as const any ptr, str1_size as ssize_t, str2 as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrConcatAssign 		FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as const FB_WCHAR ptr ) as FB_WCHAR ptr

declare function fb_WstrLen 				FBCALL ( str as FB_WCHAR ptr ) as ssize_t
declare function fb_WstrCompare 			FBCALL ( str1 as const FB_WCHAR ptr, str2 as const FB_WCHAR ptr ) as long

declare function fb_hBoolToWstr 			FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_BoolToWstr 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_IntToWstr 				FBCALL ( num as long ) as FB_WCHAR ptr
declare function fb_UIntToWstr 				FBCALL ( num as ulong ) as FB_WCHAR ptr
declare function fb_LongintToWstr 			FBCALL ( num as longint ) as FB_WCHAR ptr
declare function fb_ULongintToWstr 			FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_FloatToWstr 			FBCALL ( num as single ) as FB_WCHAR ptr
declare function fb_FloatExToWstr    			   ( val as double, buffer as FB_WCHAR ptr, digits as long, mask as long ) as FB_WCHAR ptr
declare function fb_DoubleToWstr			FBCALL ( num as double ) as FB_WCHAR ptr
declare function fb_StrToWstr 				FBCALL ( src as const ubyte ptr ) as FB_WCHAR ptr

declare function fb_WstrToStr 				FBCALL ( src as const FB_WCHAR ptr ) as FBSTRING ptr
declare function fb_WstrToDouble 			FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as double
declare function fb_WstrToBool 				FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as ubyte
declare function fb_WstrToInt 				FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as long
declare function fb_WstrToUInt 				FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as ulong
declare function fb_WstrToLongint 			FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as longint
declare function fb_WstrToULongint 			FBCALL ( src as const FB_WCHAR ptr, len as ssize_t ) as ulongint
declare function fb_WstrRadix2Int 			FBCALL ( src as const FB_WCHAR ptr, len as ssize_t, radix as long ) as long
declare function fb_WstrRadix2Longint 		FBCALL ( s as const FB_WCHAR ptr, len as ssize_t, radix as long ) as longint

declare function fb_WstrChr 					   ( args as long, ... ) as FB_WCHAR ptr
declare function fb_WstrAsc 				FBCALL ( str as const FB_WCHAR ptr, _pos as ssize_t ) as ulong
declare function fb_WstrVal 				FBCALL ( str as const FB_WCHAR ptr ) as double
declare function fb_WstrValBool 			FBCALL ( str as const FB_WCHAR ptr ) as ubyte
declare function fb_WstrValInt 				FBCALL ( str as const FB_WCHAR ptr ) as long
declare function fb_WstrValUInt 			FBCALL ( str as const FB_WCHAR ptr ) as ulong
declare function fb_WstrValLng 				FBCALL ( str as const FB_WCHAR ptr ) as longint
declare function fb_WstrValULng 			FBCALL ( str as const FB_WCHAR ptr ) as ulongint
declare function fb_WstrLeft 				FBCALL ( str as const FB_WCHAR ptr, chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrRight 				FBCALL ( str as const FB_WCHAR ptr, chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrSpace 				FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrLTrim 				FBCALL ( str as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrLTrimEx 			FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrLTrimAny 			FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrim 				FBCALL ( str as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrimEx 			FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrimAny 			FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrTrim 				FBCALL ( src as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrTrimEx 				FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrTrimAny 			FBCALL ( str as const FB_WCHAR ptr, pattern as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare sub 	 fb_WstrLset 				FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
declare sub 	 fb_WstrRset 				FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
declare function fb_WstrLcase2 				FBCALL ( src as const FB_WCHAR ptr, mode as long ) as FB_WCHAR ptr
declare function fb_WstrUcase2 				FBCALL ( src as const FB_WCHAR ptr, mode as long ) as FB_WCHAR ptr
declare function fb_WstrFill1 				FBCALL ( chars as ssize_t, c as long ) as FB_WCHAR ptr
declare function fb_WstrFill2 				FBCALL ( cnt as ssize_t, src as const FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrInstr 				FBCALL ( start as ssize_t, src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr ) as ssize_t
declare function fb_WstrInstrAny 			FBCALL ( start as ssize_t, src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr ) as ssize_t
declare function fb_WstrInstrRev 			FBCALL ( src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr, start as ssize_t ) as ssize_t
declare function fb_WstrInstrRevAny 		FBCALL ( src as const FB_WCHAR ptr, patt as const FB_WCHAR ptr, start as ssize_t ) as ssize_t
declare function fb_WstrMid 				FBCALL ( src as const FB_WCHAR ptr, start as ssize_t, len as ssize_t ) as FB_WCHAR ptr
declare sub 	 fb_WstrAssignMid 			FBCALL ( dst as FB_WCHAR ptr, dst_len as ssize_t, start as ssize_t, len as ssize_t, src as const FB_WCHAR ptr )

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * VB-compatible functions
 *************************************************************************************************'/

declare function fb_StrFormat 				FBCALL ( value as double, mask as FBSTRING ptr ) as FBSTRING ptr
declare function fb_hStrFormat 				FBCALL ( value as double, mask as const ubyte ptr, mask_length as size_t ) as FBSTRING ptr

declare function fb_VALBOOL 				FBCALL ( str as FBSTRING ptr ) as ubyte
declare function fb_VALINT 					FBCALL ( str as FBSTRING ptr ) as long
declare function fb_VALLNG 					FBCALL ( str as FBSTRING ptr ) as longint
declare function fb_VALUINT 				FBCALL ( str as FBSTRING ptr ) as ulong
declare function fb_VALULNG 				FBCALL ( str as FBSTRING ptr ) as ulongint

end extern
