
#ifdef __FB_LINUX__
        #define RAND_MAX &h7FFFFFFF
#endif

#if defined (HOST_WIN32)
Extern "C"
	Declare Function _strtoui64(ByVal valPtr As Const ZString Ptr, ByVal endPtr As ZString Ptr Ptr, ByVal radix As Long) As ULongInt
	Declare Function _strtoi64(ByVal valPtr As Const ZString Ptr, ByVal endPtr As ZString Ptr Ptr, ByVal radix As Long) As LongInt
	Declare Function _wcstoui64(ByVal str As Const wchar_t Ptr, ByVal str As wchar_t Ptr Ptr, ByVal radix As Long) As ULongInt
	Declare Function _wcstoi64(ByVal str As Const wchar_t Ptr, ByVal str As wchar_t Ptr Ptr, ByVal radix As Long) As LongInt
End Extern

	'' Windows CRT doesn't have strto(u)ll
	Private Function strtoull cdecl(ByVal valPtr As ZString Ptr, ByVal endPtr As byte Ptr Ptr, ByVal radix As Long) As ULongInt
		Return _strtoui64(valPtr, endPtr, radix)
	End Function

	Private Function strtoll cdecl(ByVal valPtr As ZString Ptr, ByVal endPtr As byte Ptr Ptr, ByVal radix As Long) As LongInt
		Return _strtoi64(valPtr, endPtr, radix)
	End Function

	Private Function wcstoull cdecl(ByVal valPtr As Const wchar_t Ptr, ByVal endPtr As wchar_t Ptr Ptr, ByVal radix As Long) As ULongInt
		Return _wcstoui64(valPtr, endPtr, radix)
	End Function

	Private Function wcstoll cdecl(ByVal valPtr As Const wchar_t Ptr, ByVal endPtr As wchar_t Ptr Ptr, ByVal radix As Long) As LongInt
		Return _wcstoi64(valPtr, endPtr, radix)
	End Function
#else
	'' The win32 one is in the crt headers as _putenv, make this an alias for non-Windows
	Declare Function _putenv alias "putenv" cdecl (byval as zstring ptr) as long
#endif
