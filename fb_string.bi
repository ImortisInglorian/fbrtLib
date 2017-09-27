/' strings '/

'These undefs will not be needed once this replaces the current RTLIB
#ifdef fb_hStrDelTemp
	#undef fb_hStrDelTemp
	#undef fb_StrInit 
	#undef fb_StrAssign
	#undef fb_StrDelete
	#undef fb_StrConcat
	#undef fb_StrConcatAssign
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


/' Flag to identify a string as a temporary string.
 *
 * This flag is stored in struct _FBSTRING::len so it's absolutely required
 * to use FB_STRSIZE(s) to query a strings length.
 '/
#ifdef HOST_64BIT
	#define FB_TEMPSTRBIT (cast(longint, &h8000000000000000ll))
#else
	#define FB_TEMPSTRBIT (cast(integer, &h80000000))
#endif

/' Returns if the string is a temporary string.
 '/
#define FB_ISTEMP(s) ((cast(FBSTRING ptr, s)->_len and FB_TEMPSTRBIT) <> 0)

/' Returns a string length.
 '/
#define FB_STRSIZE(s) (Cast(ssize_t, (cast(FBSTRING ptr, s)->_len and not(FB_TEMPSTRBIT))))

/' Returns the string data.
 '/
#define FB_STRPTR(s,size) ( iif(s = NULL, NULL , ( iif(size = -1, (Cast(FBSTRING ptr, s)->_data,  cast(ubyte ptr,s ) )))))

#macro FB_STRSETUP_FIX(s,size,_ptr,_len)
    if( s = NULL ) then 
        _ptr = NULL
        _len = 0
    else
        if( size = -1 ) then
            _ptr = cast(FBSTRING ptr, s)->_data
            _len = FB_STRSIZE( s )
        else
            _ptr = cast(ubyte ptr, s)
            /' always get the real len, as fix-len string '/
            /' will have garbage at end (nulls or spaces) '/
            _len = strlen( cast(ubyte ptr, s) )
		end if
    end if
#endmacro

#macro FB_STRSETUP_DYN(s,size,_ptr,_len)
    if( s == NULL ) then
        _ptr = NULL
        _len = 0
    else
        select case ( size )
        case -1:
            _ptr = cast(FBSTRING ptr, s)->_data
            _len = FB_STRSIZE( s )
        case 0:
            _ptr = cast(ubyte ptr, s)
            _len = strlen( _ptr )
        case else:
            _ptr = cast(ubyte ptr, s)
            _len = size - 1 /' without terminating NUL '/
        end select
    end if
#endmacro

/' Structure containing information about a specific string.
 *
 * This structure hols all informations about a specific string. This is
 * required to allow BASIC-style strings that may contain NUL characters.
 '/
type FBSTRING
    as ubyte ptr _data    /'< pointer to the real string data '/
    as ssize_t _len     /'< String length. '/
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



sub fb_hStrSetLength( _str as FBSTRING ptr, size as size_t )
    _str->_len = size or (_str->_len and FB_TEMPSTRBIT)
end sub

declare function fb_hStrAllocTmpDesc 		FBCALL ( ) as FBSTRING ptr
declare function fb_hStrDelTempDesc 		FBCALL ( _str as FBSTRING ptr ) as integer
declare function fb_hStrAlloc 				FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrRealloc 			FBCALL ( _str as FBSTRING ptr, size as ssize_t, _preserve as integer ) as FBSTRING ptr
declare function fb_hStrAllocTemp 			FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrAllocTemp_NoLock 	FBCALL ( _str as FBSTRING ptr, size as ssize_t ) as FBSTRING ptr
declare function fb_hStrDelTemp 			FBCALL ( _str as FBSTRING ptr ) as integer
declare function fb_hStrDelTemp_NoLock  	FBCALL ( _str as FBSTRING ptr ) as integer
declare sub 	 fb_hStrCopy 				FBCALL ( dst as ubyte ptr, src as ubyte const ptr , bytes as ssize_t )
declare function fb_hStrSkipChar 			FBCALL ( s as ubyte ptr, _len as ssize_t, c as integer ) as ubyte ptr
declare function fb_hStrSkipCharRev 		FBCALL ( s as ubyte ptr, _len as ssize_t, c as integer ) as ubyte ptr


/' public '/

declare function fb_StrInit 				FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as integer ) as any ptr
declare function fb_StrAssign				FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as integer ) as any ptr
declare function fb_StrAssignEx 			FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as integer, is_init as integer )as any ptr
declare sub 	 fb_StrDelete 				FBCALL ( _str as FBSTRING ptr )
declare function fb_StrConcat 				FBCALL ( dst as FBSTRING ptr, str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as FBSTRING ptr
declare function fb_StrConcatAssign 		FBCALL ( dst as any ptr, dst_size as ssize_t, src as any ptr,  src_size as ssize_t, fill_rem as integer ) as any ptr
declare function fb_StrCompare 				FBCALL ( str1 as any ptr, str1_size as ssize_t, str2 as any ptr, str2_size as ssize_t ) as integer
declare function fb_StrAllocTempResult 		FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrAllocTempDescF		FBCALL ( _str as ubyte ptr, str_size as ssize_t ) as FBSTRING ptr
declare function fb_StrAllocTempDescV		FBCALL ( _str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrAllocTempDescZEx 	FBCALL ( _str as ubyte const ptr, _len as ssize_t ) as FBSTRING ptr
declare function fb_StrAllocTempDescZ 		FBCALL ( _str as ubyte const ptr ) as FBSTRING ptr
declare function fb_StrLen 					FBCALL ( _str as any ptr, str_size as ssize_t ) as long

declare function fb_hBoolToStr 				FBCALL ( num as ubyte ) as ubyte ptr
declare function fb_BoolToStr 				FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_IntToStr 				FBCALL ( num as integer ) as FBSTRING ptr
declare function fb_IntToStrQB 				FBCALL ( num as long ) as FBSTRING ptr
declare function fb_UIntToStr 				FBCALL ( num as uinteger ) as FBSTRING ptr
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

declare function fb_hStr2Bool 				FBCALL ( src as ubyte ptr, _len as ssize_t ) as ubyte
declare function fb_hStr2Double 			FBCALL ( src as ubyte ptr, _len as ssize_t ) as double
declare function fb_hStr2Int 				FBCALL ( src as ubyte ptr, _len as ssize_t ) as integer
declare function fb_hStr2UInt 				FBCALL ( src as ubyte ptr, _len as ssize_t ) as uinteger
declare function fb_hStr2Longint 			FBCALL ( src as ubyte ptr, _len as ssize_t ) as longint
declare function fb_hStr2ULongint 			FBCALL ( src as ubyte ptr, _len as ssize_t ) as ulongint
declare function fb_hStrRadix2Int 			FBCALL ( src as ubyte ptr, _len as ssize_t, radix as integer ) as integer
declare function fb_hStrRadix2Longint 		FBCALL ( s as ubyte ptr, _len as ssize_t, radix as integer ) as longint
declare function fb_hFloat2Str       		cdecl	( _val as double, buffer as ubyte ptr, digits as integer, mask as integer ) as ubyte ptr

declare function fb_CHR              		cdecl	( args as integer, ... ) as FBSTRING ptr
declare function fb_ASC 					FBCALL ( _str as FBSTRING ptr, _pos as ssize_t ) as uinteger
declare function fb_VAL 					FBCALL ( _str as FBSTRING ptr ) as double
declare function fb_CVD 					FBCALL ( _str as FBSTRING ptr ) as double
declare function fb_CVS 					FBCALL ( _str as FBSTRING ptr ) as single
declare function fb_CVSHORT 				FBCALL ( _str as FBSTRING ptr ) as short
declare function fb_CVI 					FBCALL ( _str as FBSTRING ptr ) as integer /' 32bit legacy '/
declare function fb_CVL 					FBCALL ( _str as FBSTRING ptr ) as integer
declare function fb_CVLONGINT 				FBCALL ( _str as FBSTRING ptr ) as longint
declare function fb_HEX 					FBCALL ( num as integer ) as FBSTRING ptr
declare function fb_OCT 					FBCALL ( num as integer) as FBSTRING ptr
declare function fb_BIN 					FBCALL ( num as integer ) as FBSTRING ptr

declare function fb_BIN_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_BIN_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_BIN_i 					FBCALL ( num as uinteger ) as FBSTRING ptr
declare function fb_BIN_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_BIN_p 					FBCALL ( p as any const ptr ) as FBSTRING ptr
declare function fb_BINEx_b 				FBCALL ( num as ubyte, digits as integer ) as FBSTRING ptr
declare function fb_BINEx_s 				FBCALL ( num as ushort, digits as integer ) as FBSTRING ptr
declare function fb_BINEx_i 				FBCALL ( num as uinteger, digits as integer ) as FBSTRING ptr
declare function fb_BINEx_l 				FBCALL ( num as ulongint, digits as integer ) as FBSTRING ptr
declare function fb_BINEx_p 				FBCALL ( p as any const ptr, digits as integer ) as FBSTRING ptr

declare function fb_OCT_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_OCT_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_OCT_i 					FBCALL ( num as uinteger ) as FBSTRING ptr
declare function fb_OCT_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_OCT_p 					FBCALL ( p as any const ptr ) as FBSTRING ptr
declare function fb_OCTEx_b 				FBCALL ( num as ubyte, digits as integer ) as FBSTRING ptr
declare function fb_OCTEx_s 				FBCALL ( num as ushort, digits as integer ) as FBSTRING ptr
declare function fb_OCTEx_i 				FBCALL ( num as uinteger, digits as integer ) as FBSTRING ptr
declare function fb_OCTEx_l 				FBCALL ( num as ulongint, digits as integer ) as FBSTRING ptr
declare function fb_OCTEx_p 				FBCALL ( p as any const ptr, digits as integer ) as FBSTRING ptr

declare function fb_HEX_b 					FBCALL ( num as ubyte ) as FBSTRING ptr
declare function fb_HEX_s 					FBCALL ( num as ushort ) as FBSTRING ptr
declare function fb_HEX_i 					FBCALL ( num as uinteger ) as FBSTRING ptr
declare function fb_HEX_l 					FBCALL ( num as ulongint ) as FBSTRING ptr
declare function fb_HEX_p 					FBCALL ( p as any const ptr ) as FBSTRING ptr
declare function fb_HEXEx_b 				FBCALL ( num as ubyte, digits as integer ) as FBSTRING ptr
declare function fb_HEXEx_s 				FBCALL ( num as ushort, digits as integer ) as FBSTRING ptr
declare function fb_HEXEx_i 				FBCALL ( num as uinteger, digits as integer ) as FBSTRING ptr
declare function fb_HEXEx_l 				FBCALL ( num as ulongint, digits as integer ) as FBSTRING ptr
declare function fb_HEXEx_p 				FBCALL ( p as any const ptr, digits as integer ) as FBSTRING ptr

declare function fb_WstrBin_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrBin_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrBin_i 				FBCALL ( num as uinteger ) as FB_WCHAR ptr
declare function fb_WstrBin_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrBin_p 				FBCALL ( p as any const ptr ) as FB_WCHAR ptr
declare function fb_WstrBinEx_b 			FBCALL ( num as ubyte, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrBinEx_s 			FBCALL ( num as ushort, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrBinEx_i 			FBCALL ( num as uinteger, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrBinEx_l 			FBCALL ( num as ulongint, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrBinEx_p 			FBCALL ( p as any const ptr, digits as integer ) as FB_WCHAR ptr

declare function fb_WstrHex_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrHex_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrHex_i 				FBCALL ( num as uinteger ) as FB_WCHAR ptr
declare function fb_WstrHex_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrHex_p 				FBCALL ( p as any const ptr ) as FB_WCHAR ptr
declare function fb_WstrHexEx_b 			FBCALL ( num as ubyte, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrHexEx_s 			FBCALL ( num as ushort, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrHexEx_i 			FBCALL ( num as uinteger, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrHexEx_l 			FBCALL ( num as ulongint, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrHexEx_p 			FBCALL ( p as any const ptr, digits as integer ) as FB_WCHAR ptr

declare function fb_WstrOct_b 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_WstrOct_s 				FBCALL ( num as ushort ) as FB_WCHAR ptr
declare function fb_WstrOct_i 				FBCALL ( num as uinteger ) as FB_WCHAR ptr
declare function fb_WstrOct_l 				FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_WstrOct_p 				FBCALL ( p as any const ptr ) as FB_WCHAR ptr
declare function fb_WstrOctEx_b 			FBCALL ( num as ubyte, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrOctEx_s 			FBCALL ( num as ushort, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrOctEx_i 			FBCALL ( num as uinteger, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrOctEx_l 			FBCALL ( num as ulongint, digits as integer ) as FB_WCHAR ptr
declare function fb_WstrOctEx_p 			FBCALL ( p as any const ptr, digits as integer ) as FB_WCHAR ptr

declare function fb_MKD 					FBCALL ( num as double ) as FBSTRING ptr
declare function fb_MKS 					FBCALL ( num as single ) as FBSTRING ptr
declare function fb_MKSHORT 				FBCALL ( num as short ) as FBSTRING ptr
declare function fb_MKI 					FBCALL ( num as integer ) as FBSTRING ptr
declare function fb_MKL 					FBCALL ( num as long ) as FBSTRING ptr
declare function fb_MKLONGINT 				FBCALL ( num as longint ) as FBSTRING ptr
declare function fb_LEFT 					FBCALL ( _str as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
declare function fb_RIGHT 					FBCALL ( _str as FBSTRING ptr, chars as ssize_t ) as FBSTRING ptr
declare function fb_SPACE 					FBCALL ( chars as ssize_t ) as FBSTRING ptr
declare function fb_LTRIM 					FBCALL ( _str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_LTrimEx 				FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_LTrimAny 				FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTRIM 					FBCALL ( _str as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTrimEx 				FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_RTrimAny 				FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TRIM 					FBCALL ( src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TrimEx 					FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare function fb_TrimAny 				FBCALL ( _str as FBSTRING ptr, pattern as FBSTRING ptr ) as FBSTRING ptr
declare sub 	 fb_StrLset 				FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
declare sub 	 fb_StrRset 				FBCALL ( dst as FBSTRING ptr, src as FBSTRING ptr )
declare function fb_StrLcase2 				FBCALL ( src as FBSTRING ptr, mode as integer ) as FBSTRING ptr
declare function fb_StrUcase2 				FBCALL ( src as FBSTRING ptr, mode as integer ) as FBSTRING ptr
declare function fb_StrFill1 				FBCALL ( cnt as ssize_t, fchar as integer ) as FBSTRING ptr
declare function fb_StrFill2 				FBCALL ( cnt as ssize_t, src as FBSTRING ptr ) as FBSTRING ptr
declare function fb_StrInstr 				FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
declare function fb_StrInstrAny 			FBCALL ( start as ssize_t, src as FBSTRING ptr, patt as FBSTRING ptr ) as ssize_t
declare function fb_StrInstrRev 			FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
declare function fb_StrInstrRevAny 			FBCALL ( src as FBSTRING ptr, patt as FBSTRING ptr, start as ssize_t ) as ssize_t
declare function fb_StrMid 					FBCALL ( src as FBSTRING ptr, start as ssize_t, _len as ssize_t ) as FBSTRING ptr
declare sub 	 fb_StrAssignMid 			FBCALL ( dst as FBSTRING ptr, start as ssize_t, _len as ssize_t, src as FBSTRING ptr )

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * Unicode strings
 *************************************************************************************************'/

declare function fb_WstrAlloc 				FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrAssignToA_Init 		FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as integer ) as any ptr
declare sub 	 fb_WstrDelete 				FBCALL ( _str as FB_WCHAR ptr )
declare function fb_WstrAssign 				FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrAssignFromA 		FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as any ptr, src_chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrAssignToA 			FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as integer ) as any ptr
declare function fb_WstrAssignToAEx 		FBCALL ( dst as any ptr, dst_chars as ssize_t, src as FB_WCHAR ptr, fill_rem as integer, is_init as integer ) as any ptr
declare function fb_WstrConcat 				FBCALL ( str1 as FB_WCHAR const ptr, str2 as FB_WCHAR const ptr )  as FB_WCHAR ptr
declare function fb_WstrConcatWA 			FBCALL ( str1 as FB_WCHAR const ptr, str2 as any const ptr, str2_size as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrConcatAW 			FBCALL ( str1 as any const ptr, str1_size as ssize_t, str2 as FB_WCHAR ptr ) as FB_WCHAR ptr
declare function fb_WstrConcatAssign 		FBCALL ( dst as FB_WCHAR ptr, dst_chars as ssize_t, src as FB_WCHAR const ptr ) as FB_WCHAR ptr

declare function fb_WstrLen 				FBCALL ( _str as FB_WCHAR ptr ) as ssize_t
declare function fb_WstrCompare 			FBCALL ( str1 as FB_WCHAR const ptr, str2 as FB_WCHAR const ptr ) as integer

declare function fb_hBoolToWstr 			FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_BoolToWstr 				FBCALL ( num as ubyte ) as FB_WCHAR ptr
declare function fb_IntToWstr 				FBCALL ( num as integer ) as FB_WCHAR ptr
declare function fb_UIntToWstr 				FBCALL ( num as uinteger ) as FB_WCHAR ptr
declare function fb_LongintToWstr 			FBCALL ( num as longint ) as FB_WCHAR ptr
declare function fb_ULongintToWstr 			FBCALL ( num as ulongint ) as FB_WCHAR ptr
declare function fb_FloatToWstr 			FBCALL ( num as single ) as FB_WCHAR ptr
declare function fb_FloatExToWstr    			   ( _val as double, buffer as FB_WCHAR ptr, digits as integer, mask as integer ) as FB_WCHAR ptr
declare function fb_DoubleToWstr			FBCALL ( num as double ) as FB_WCHAR ptr
declare function fb_StrToWstr 				FBCALL ( src as ubyte const ptr ) as FB_WCHAR ptr

declare function fb_WstrToStr 				FBCALL ( src as FB_WCHAR const ptr ) as FBSTRING ptr
declare function fb_WstrToDouble 			FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as double
declare function fb_WstrToBool 				FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as ubyte
declare function fb_WstrToInt 				FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as integer
declare function fb_WstrToUInt 				FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as uinteger
declare function fb_WstrToLongint 			FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as longint
declare function fb_WstrToULongint 			FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t ) as ulongint
declare function fb_WstrRadix2Int 			FBCALL ( src as FB_WCHAR const ptr, _len as ssize_t, radix as integer ) as integer
declare function fb_WstrRadix2Longint 		FBCALL ( s as FB_WCHAR const ptr, _len as ssize_t, radix as integer ) as longint

declare function fb_WstrChr 				cdecl  ( args as integer, ... ) as FB_WCHAR ptr
declare function fb_WstrAsc 				FBCALL ( _str as FB_WCHAR const ptr, _pos as ssize_t ) as uinteger
declare function fb_WstrVal 				FBCALL ( _str as FB_WCHAR const ptr ) as double
declare function fb_WstrValBool 			FBCALL ( _str as FB_WCHAR const ptr ) as ubyte
declare function fb_WstrValInt 				FBCALL ( _str as FB_WCHAR const ptr ) as integer
declare function fb_WstrValUInt 			FBCALL ( _str as FB_WCHAR const ptr ) as uinteger
declare function fb_WstrValLng 				FBCALL ( _str as FB_WCHAR const ptr ) as longint
declare function fb_WstrValULng 			FBCALL ( _str as FB_WCHAR const ptr ) as ulongint
declare function fb_WstrLeft 				FBCALL ( _str as FB_WCHAR const ptr, chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrRight 				FBCALL ( _str as FB_WCHAR const ptr, chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrSpace 				FBCALL ( chars as ssize_t ) as FB_WCHAR ptr
declare function fb_WstrLTrim 				FBCALL ( _str as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrLTrimEx 			FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrLTrimAny 			FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrim 				FBCALL ( _str as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrimEx 			FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrRTrimAny 			FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrTrim 				FBCALL ( src as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrTrimEx 				FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrTrimAny 			FBCALL ( _str as FB_WCHAR const ptr, pattern as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare sub 	 fb_WstrLset 				FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
declare sub 	 fb_WstrRset 				FBCALL ( dst as FB_WCHAR ptr, src as FB_WCHAR ptr )
declare function fb_WstrLcase2 				FBCALL ( src as FB_WCHAR const ptr, mode as integer ) as FB_WCHAR ptr
declare function fb_WstrUcase2 				FBCALL ( src as FB_WCHAR const ptr, mode as integer ) as FB_WCHAR ptr
declare function fb_WstrFill1 				FBCALL ( chars as ssize_t, c as integer ) as FB_WCHAR ptr
declare function fb_WstrFill2 				FBCALL ( cnt as ssize_t, src as FB_WCHAR const ptr ) as FB_WCHAR ptr
declare function fb_WstrInstr 				FBCALL ( start as ssize_t, src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr ) as ssize_t
declare function fb_WstrInstrAny 			FBCALL ( start as ssize_t, src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr ) as ssize_t
declare function fb_WstrInstrRev 			FBCALL ( src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr, start as ssize_t ) as ssize_t
declare function fb_WstrInstrRevAny 		FBCALL ( src as FB_WCHAR const ptr, patt as FB_WCHAR const ptr, start as ssize_t ) as ssize_t
declare function fb_WstrMid 				FBCALL ( src as FB_WCHAR const ptr, start as ssize_t, _len as ssize_t ) as FB_WCHAR ptr
declare sub 	 fb_WstrAssignMid 			FBCALL ( dst as FB_WCHAR ptr, dst_len as ssize_t, start as ssize_t, _len as ssize_t, src as FB_WCHAR const ptr )

/''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 * VB-compatible functions
 *************************************************************************************************'/

declare function fb_StrFormat 				FBCALL ( value as double, mask as FBSTRING ptr ) as FBSTRING ptr
declare function fb_hStrFormat 				FBCALL ( value as double, mask as ubyte const ptr, mask_length as size_t ) as FBSTRING ptr

declare function fb_VALBOOL 				FBCALL ( _str as FBSTRING ptr ) as ubyte
declare function fb_VALINT 					FBCALL ( _str as FBSTRING ptr ) as integer
declare function fb_VALLNG 					FBCALL ( _str as FBSTRING ptr ) as longint
declare function fb_VALUINT 				FBCALL ( _str as FBSTRING ptr ) as uinteger
declare function fb_VALULNG 				FBCALL ( _str as FBSTRING ptr ) as ulongint