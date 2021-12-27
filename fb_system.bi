#ifdef fb_Init
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

declare function fb_CpuDetect 				       ( ) as ulong
declare sub 	 fb_Init 					FBCALL ( argc as long, argv as ubyte ptr ptr, lang as long )
declare sub 	 fb_End 					FBCALL ( errlevel as long )
declare sub 	 fb_RtInit 				       	   ( )
declare sub 	 fb_RtExit 				       	   ( )
declare sub 	 fb_InitSignals 			FBCALL ( )

declare sub 	 fb_MemSwap 				FBCALL ( dst as ubyte ptr, src as ubyte ptr, bytes as ssize_t )
declare sub 	 fb_StrSwap 				FBCALL ( str1 as any ptr, size1 as ssize_t, fillrem1 as long, str2 as any ptr, size2 as ssize_t, fillrem2 as long )
declare sub 	 fb_WstrSwap 				FBCALL ( str1 as FB_WCHAR ptr, size1 as ssize_t, str2 as FB_WCHAR ptr, size2 as ssize_t )
declare sub 	 fb_MemCopyClear 			FBCALL ( dst as ubyte ptr, dstlen as size_t, src as ubyte ptr, srclen as size_t )

declare sub 	 fb_hInit 						   ( )
declare sub 	 fb_hEnd 						   ( errlevel as long )

declare sub 	 fb_Beep 					FBCALL ( )

declare function fb_Command 				FBCALL ( argc as long, result as FBSTRING ptr ) as FBSTRING ptr
declare function fb_GetEnviron 				FBCALL ( varname as FBSTRING ptr, result as FBSTRING ptr ) as FBSTRING ptr
declare function fb_SetEnviron 				FBCALL ( str as FBSTRING ptr ) as long
declare function fb_CurDir 					FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
declare function fb_ExePath 				FBCALL ( result as FBSTRING ptr ) as FBSTRING ptr
declare function fb_Shell 					FBCALL ( program as FBSTRING ptr ) as long
declare function fb_hShell 				    	   ( program as ubyte ptr ) as long
declare function fb_Run 					FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as long
declare function fb_Chain 					FBCALL ( program as FBSTRING ptr ) as long
declare function fb_Exec 					FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr ) as long
declare function fb_ExecEx 					FBCALL ( program as FBSTRING ptr, args as FBSTRING ptr, do_wait as long ) as long
declare function fb_hParseArgs 					   ( dst as ubyte ptr, src as const ubyte ptr, length as ssize_t ) as long

declare function fb_GetMemAvail 			FBCALL ( mode as long ) as size_t

declare function fb_DylibLoad 				FBCALL ( library as FBSTRING ptr ) as any ptr
declare function fb_DylibSymbol 			FBCALL ( library as any ptr, symbol as FBSTRING ptr ) as any ptr
declare function fb_DylibSymbolByOrd 		FBCALL ( library as any ptr, symbol as short ) as any ptr
declare sub 	 fb_DylibFree 				FBCALL ( library as any ptr )

declare function fb_hGetShortPath 			       ( src as ubyte ptr, dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

declare function fb_hGetCurrentDir 			       ( dst as ubyte ptr, maxlen as ssize_t ) as ssize_t
declare function fb_hGetExePath 			       ( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr
declare function fb_hGetExeName 			       ( dst as ubyte ptr, maxlen as ssize_t ) as ubyte ptr

declare function fb_hIn 					       ( port as ushort ) as long
declare function fb_hOut 					       ( port as ushort, value as ubyte ) as long
declare function fb_Wait 					FBCALL ( port as ushort, val_and as long, val_xor as long ) as long

declare sub 	 fb_hRtInit 				       ( )
declare sub 	 fb_hRtExit 				       ( )
end extern
