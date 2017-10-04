#ifdef fb_CpuDetect 
	#undef fb_CpuDetect 
	#undef fb_Init
	#undef fb_End
	#undef fb_InitSignals
	#undef fb_MemSwap
	#undef fb_StrSwap
	#undef fb_WstrSwap
	#undef fb_MemCopyClear
	#undef fb_Beep
	#undef fb_Command
#endif

extern "C"

declare function fb_CpuDetect 			cdecl  ( ) as unsigned integer
declare sub 	 fb_Init 				FBCALL ( argc as integer, argv as ubyte ptr ptr, lang as integer )
declare sub 	 fb_End 				FBCALL ( errlevel as integer )
declare sub 	 fb_RtInit 				cdecl  ( )
declare sub 	 fb_RtExit 				cdecl  ( )
declare sub 	 fb_InitSignals 		FBCALL ( )

declare sub 	 fb_MemSwap 			FBCALL ( dst as ubyte ptr, src as ubyte ptr, bytes as ssize_t )
declare sub 	 fb_StrSwap 			FBCALL ( str1 as any ptr, size1 as ssize_t, fillrem1 as integer, str2 as any ptr, size2 as ssize_t, fillrem2 as integer )
declare sub 	 fb_WstrSwap 			FBCALL ( str1 as FB_WCHAR ptr, size1 as ssize_t, str2 as FB_WCHAR ptr, size2 as ssize_t )
declare sub 	 fb_MemCopyClear 		FBCALL ( dst as ubyte ptr, dstlen as ssize_t, src as ubyte ptr, srclen as ssize_t )

declare sub 	 fb_hInit 				cdecl  ( )
declare sub 	 fb_hEnd 				cdecl  ( errlevel as integer )

declare sub 	 fb_Beep 				FBCALL ( )

declare function fb_Command 			FBCALL ( argc as integer ) as FBSTRING ptr
declare function fb_GetEnviron 			FBCALL ( varname as FBSTRING ptr ) as FBSTRING ptr
declare function fb_SetEnviron 			FBCALL ( _str as FBSTRING ptr ) as integer
declare function fb_CurDir 				FBCALL ( ) as FBSTRING ptr
declare function fb_ExePath 			FBCALL ( ) as FBSTRING ptr
declare function fb_Shell 				FBCALL ( program as FBSTRING ptr ) as integer
declare function fb_hShell 				cdecl  ( program as ubyte ptr ) as integer
declare function fb_Run 				FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as integer
declare function fb_Chain 				FBCALL ( program as FBSTRING ptr ) as integer
declare function fb_Exec 				FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as integer
declare function fb_ExecEx 				FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr, do_wait as integer ) as integer
declare function fb_hParseArgs 			cdecl  ( dst as ubyte ptr, src as ubyte const ptr, length as ssize_t ) as integer

declare function fb_GetMemAvail 		FBCALL ( mode as integer ) as size_t

declare function fb_DylibLoad 			FBCALL ( library as FBSTRING ptr ) as any ptr
declare function fb_DylibSymbol 		FBCALL ( library as any ptr, symbol as FBSTRING ptr ) as any ptr
declare function fb_DylibSymbolByOrd 	FBCALL ( library as any ptr, symbol as short ) as any ptr
declare sub 	 fb_DylibFree 			FBCALL ( library as any ptr )

declare function fb_hGetShortPath 		cdecl  ( src as ubyte ptr, dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

declare function fb_hGetCurrentDir 		cdecl  ( dst as ubyte ptr, maxlen as ssize_t ) as ssize_t
declare function fb_hGetExePath 		cdecl  ( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
declare function fb_hGetExeName 		cdecl  ( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

declare function fb_hIn 				cdecl  ( port as ushort ) as integer
declare function fb_hOut 				cdecl  ( port as ushort, value as ubyte ) as integer
declare function fb_Wait 				FBCALL ( port as ushort, val_and as integer, val_xor as integer ) as integer

declare sub 	 fb_hRtInit 			cdecl  ( )
declare sub 	 fb_hRtExit 			cdecl  ( )
end extern