#ifdef FB_PRINTWSTR
	#undef FB_PRINTWSTR
	#undef fb_PrintVoid
	#undef fb_PrintBool
	#undef fb_PrintByte
	#undef fb_PrintUByte
	#undef fb_PrintShort
	#undef fb_PrintUShort
	#undef fb_PrintInt
	#undef fb_PrintUInt
	#undef fb_PrintLongint
	#undef fb_PrintULongint
	#undef fb_PrintSingle
	#undef fb_PrintDouble
	#undef fb_PrintString
	#undef fb_PrintWstr
	#undef fb_LPrintVoid
	#undef fb_LPrintBool
	#undef fb_LPrintByte
	#undef fb_LPrintUByte
	#undef fb_LPrintShort
	#undef fb_LPrintUShort
	#undef fb_LPrintInt
	#undef fb_LPrintUInt
	#undef fb_LPrintLongint
	#undef fb_LPrintULongint
	#undef fb_LPrintSingle
	#undef fb_LPrintDouble
	#undef fb_LPrintString
	#undef fb_LPrintWstr 
	#undef fb_PrintTab
	#undef fb_PrintSPC
	#undef fb_WriteVoid
	#undef fb_WriteBool
	#undef fb_WriteByte
	#undef fb_WriteUByte
	#undef fb_WriteShort
	#undef fb_WriteUShort
	#undef fb_WriteInt
	#undef fb_WriteUInt
	#undef fb_WriteLongint
	#undef fb_WriteULongint
	#undef fb_WriteSingle
	#undef fb_WriteDouble
	#undef fb_WriteString
	#undef fb_WriteWstr
	#undef fb_PrintUsingInit
	#undef fb_PrintUsingStr
	#undef fb_PrintUsingWstr
	#undef fb_PrintUsingSingle
	#undef fb_PrintUsingDouble
	#undef fb_PrintUsingLongint
	#undef fb_PrintUsingULongint
	#undef fb_PrintUsingEnd
	#undef fb_LPrintUsingInit
#endif

#define FB_PRINT_NEWLINE      &h00000001
#define FB_PRINT_PAD          &h00000002
#define FB_PRINT_BIN_NEWLINE  &h00000004
#define FB_PRINT_FORCE_ADJUST &h00000008     /' Enforce position adjustment
                                              * when last character in screen
                                              * buffer gets handles in a special
                                              * way '/
#define FB_PRINT_APPEND_SPACE &h00000010
#define FB_PRINT_ISLAST       &h80000000     /' only for USING '/

/' Small helper function that converts the TEXT new-line flag to the BINARY
   new-line flag. This is used by all the LPRINT functions, to allow them to
   use the same public API like the normal PRINT functions. '/
private function FB_PRINT_CONVERT_BIN_NEWLINE( mask as long ) as long
	if ( mask and FB_PRINT_NEWLINE ) then
		mask = (mask and not(FB_PRINT_NEWLINE)) or FB_PRINT_BIN_NEWLINE
	end if
	return mask
end function

/' masked bits for "high level" flags, i.e. flags that are set by the
   BASIC PRINT command directly. '/
#define FB_PRINT_HLMASK  &h00000003

#define FB_PRINT_EX(handle, s, _len, mask) fb_hFilePrintBufferEx( handle, s, _len )

#define FB_PRINT(fnum, s, mask) FB_PRINT_EX( FB_FILE_TO_HANDLE(fnum), s, strlen(s), 0 )

#define FB_PRINTWSTR_EX(handle, s, _len, mask) fb_hFilePrintBufferWstrEx( handle, s, _len )

#define _FB_PRINTWSTR(fnum, s, mask) FB_PRINTWSTR_EX( FB_FILE_TO_HANDLE(fnum), s, fb_wstr_len(s), 0 )

#macro FB_PRINTNUM_EX(handle, _val, mask, fmt, _type)
	dim as ubyte ptr buffer(0 to 79)
	dim as size_t _len
	
	if ( mask and FB_PRINT_APPEND_SPACE ) then
		if ( mask and FB_PRINT_BIN_NEWLINE ) then
			_len = sprintf( buffer, fmt _type " " FB_BINARY_NEWLINE, _val )
		elseif ( mask and FB_PRINT_NEWLINE ) then
			_len = sprintf( buffer, fmt _type " " FB_NEWLINE, _val )
		else
			_len = sprintf( buffer, fmt _type " ", _val )
		end if
	else
		if ( mask and FB_PRINT_BIN_NEWLINE ) then
			_len = sprintf( buffer, fmt _type FB_BINARY_NEWLINE, _val )
		elseif ( mask and FB_PRINT_NEWLINE ) then
			_len = sprintf( buffer, fmt _type FB_NEWLINE, _val )
		else
			_len = sprintf( buffer, fmt _type, _val )
		end if
	end if

	FB_PRINT_EX( handle, buffer, _len, mask )

	if( mask and FB_PRINT_PAD ) then
		fb_PrintPadEx ( handle, mask )
	end if
#endmacro

#define FB_PRINTNUM(fnum, _val, mask, fmt, _type) FB_PRINTNUM_EX( FB_FILE_TO_HANDLE(fnum), _val, mask, fmt, _type )

#macro FB_WRITENUM_EX(handle, _val, mask, _type )
	dim as ubyte ptr buffer(0 to 79)
	dim as size_t _len

	if ( mask and FB_PRINT_BIN_NEWLINE ) then
		_len = sprintf( buffer, _type FB_BINARY_NEWLINE, _val )
	elseif ( mask and FB_PRINT_NEWLINE ) then
		_len = sprintf( buffer, _type FB_NEWLINE, _val )
	else
		_len = sprintf( buffer, _type ",", _val )
	end if

	fb_hFilePrintBufferEx( handle, buffer, _len )
#endmacro

#define FB_WRITENUM(fnum, _val, mask, _type)  FB_WRITENUM_EX(FB_FILE_TO_HANDLE(fnum), _val, mask, _type)

extern "C"
declare sub 	 fb_PrintBuffer      	FBCALL ( s as ubyte const ptr, mask as long )
declare sub 	 fb_PrintBufferEx    	FBCALL ( buffer as any const ptr, _len as size_t, mask as long )
declare sub 	 fb_PrintBufferWstrEx 	FBCALL ( buffer as FB_WCHAR const ptr, _len as size_t, mask as long )

declare sub 	 fb_PrintPad         	FBCALL ( fnum as long, mask as long )
declare sub 	 fb_PrintPadEx       	cdecl  ( handle as FB_FILE ptr, mask as long )
declare sub 	 fb_PrintPadWstr     	FBCALL ( fnum as long, mask as long )
declare sub 	 fb_PrintPadWstrEx   	cdecl  ( handle as FB_FILE ptr, mask as long )

declare sub 	 fb_PrintVoid        	FBCALL ( fnum as long, mask as long )
declare sub 	 fb_PrintVoidEx      	cdecl  ( handle as FB_FILE ptr, mask as long )
declare sub 	 fb_PrintVoidWstr    	FBCALL ( fnum as long, mask as long )
declare sub 	 fb_PrintVoidWstrEx  	cdecl  ( handle as FB_FILE ptr, mask as long )

declare sub 	  fb_PrintBool        	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_PrintByte        	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_PrintUByte       	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_PrintShort       	FBCALL ( fnum as long, _val as short, mask as long )
declare sub 	  fb_PrintUShort      	FBCALL ( fnum as long, _val as ushort, mask as long )
declare sub 	  fb_PrintInt         	FBCALL ( fnum as long, _val as long, mask as long )
declare sub 	  fb_PrintUInt        	FBCALL ( fnum as long, _val as ulong, mask as long )
declare sub 	  fb_PrintLongint     	FBCALL ( fnum as long, _val as longint, mask as long )
declare sub 	  fb_PrintULongint    	FBCALL ( fnum as long, _val as ulongint, mask as long )
declare sub 	  fb_PrintSingle      	FBCALL ( fnum as long, _val as single, mask as long )
declare sub 	  fb_PrintDouble      	FBCALL ( fnum as long, _val as double, mask as long )
declare sub 	  fb_PrintString      	FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
declare sub 	  fb_PrintStringEx    	cdecl  ( handle as FB_FILE ptr, s as FBSTRING ptr, mask as long )
declare sub 	  fb_PrintWstr        	FBCALL ( fnum as long, s as FB_WCHAR const ptr, mask as long )
declare sub 	  fb_PrintWstrEx      	cdecl  ( handle as FB_FILE ptr, s as FB_WCHAR const ptr, mask as long )
declare sub 	  fb_PrintFixString   	FBCALL ( fnum as long, s as ubyte const ptr, mask as long )
declare sub 	  fb_PrintFixStringEx 	cdecl  ( handle as FB_FILE ptr, s as ubyte const ptr, mask as long )

declare function fb_LPos 					FBCALL ( printer_index as long ) as long
declare function fb_LPrintInit 			cdecl  ( ) as long
declare sub 	  fb_LPrintVoid       	FBCALL ( fnum as long, mask as long )
declare sub 	  fb_LPrintBool       	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_LPrintByte       	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_LPrintUByte      	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_LPrintShort      	FBCALL ( fnum as long, _val as short, mask as long )
declare sub 	  fb_LPrintUShort     	FBCALL ( fnum as long, _val as ushort, mask as long )
declare sub 	  fb_LPrintInt        	FBCALL ( fnum as long, _val as long, mask as long )
declare sub 	  fb_LPrintUInt       	FBCALL ( fnum as long, _val as ulong, mask as long )
declare sub 	  fb_LPrintLongint    	FBCALL ( fnum as long, _val as longint, mask as long )
declare sub 	  fb_LPrintULongint   	FBCALL ( fnum as long, _val as ulongint, mask as long )
declare sub 	  fb_LPrintSingle     	FBCALL ( fnum as long, _val as single, mask as long )
declare sub 	  fb_LPrintDouble     	FBCALL ( fnum as long, _val as double, mask as long )
declare sub 	  fb_LPrintString     	FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
declare sub 	  fb_LPrintWstr       	FBCALL ( fnum as long, s as FB_WCHAR const ptr, mask as long )

declare sub 	  fb_PrintTab         	FBCALL ( fnum as long, newcol as long )
declare sub 	  fb_PrintSPC         	FBCALL ( fnum as long, n as ssize_t )

declare sub 	  fb_WriteVoid        	FBCALL ( fnum as long, mask as long )
declare sub 	  fb_WriteBool        	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_WriteByte        	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_WriteUByte       	FBCALL ( fnum as long, _val as ubyte ptr, mask as long )
declare sub 	  fb_WriteShort       	FBCALL ( fnum as long, _val as short, mask as long )
declare sub 	  fb_WriteUShort      	FBCALL ( fnum as long, _val as ushort, mask as long )
declare sub 	  fb_WriteInt         	FBCALL ( fnum as long, _val as long, mask as long )
declare sub 	  fb_WriteUInt        	FBCALL ( fnum as long, _val as ulong, mask as long )
declare sub 	  fb_WriteLongint     	FBCALL ( fnum as long, _val as longint, mask as long )
declare sub 	  fb_WriteULongint    	FBCALL ( fnum as long, _val as ulongint, mask as long )
declare sub 	  fb_WriteSingle      	FBCALL ( fnum as long, _val as single, mask as long )
declare sub 	  fb_WriteDouble      	FBCALL ( fnum as long, _val as double, mask as long )
declare sub 	  fb_WriteString      	FBCALL ( fnum as long, s as FBSTRING ptr, mask as long )
declare sub 	  fb_WriteWstr        	FBCALL ( fnum as long, s as FB_WCHAR ptr, mask as long )
declare sub 	  fb_WriteFixString   	FBCALL ( fnum as long, s as ubyte ptr, mask as long )

declare function fb_PrintUsingInit   	FBCALL ( fmtstr as FBSTRING ptr ) as long
declare function fb_PrintUsingStr    	FBCALL ( fnum as long, s as FBSTRING ptr, mask as long ) as long
declare function fb_PrintUsingWstr   	FBCALL ( fnum as long, s as FB_WCHAR ptr, mask as long ) as long
declare function fb_PrintUsingSingle 	FBCALL ( fnum as long, value_f as single, mask as long ) as long
declare function fb_PrintUsingDouble 	FBCALL ( fnum as long, value as double, mask as long ) as long
declare function fb_PrintUsingLongint 	FBCALL ( fnum as long, val_ll as longint, mask as long ) as long
declare function fb_PrintUsingULongint FBCALL ( fnum as long, value_ull as ulongint, mask as long ) as long
declare function fb_PrintUsingEnd    	FBCALL ( fnum as long ) as long

declare function fb_LPrintUsingInit  	FBCALL ( fmtstr as FBSTRING ptr ) as long
end extern