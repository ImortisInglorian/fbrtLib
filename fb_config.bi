#Ifndef __FB_CONFIG_BI__
#Define __FB_CONFIG_BI__

#If Defined (HOST_XBOX)
#elseif defined (__FB_DOS__)
	#define HOST_DOS
#elseif defined (__FB_WIN32__) /' MinGW, MinGW-w64, TDM-GCC '/
	#define HOST_WIN32
	/' We prefer using non-oldnames functions, see also win32/fb_win32.h '/
	#define NO_OLDNAMES
	#define _NO_OLDNAMES
	/' Tell windows.h to omit many headers we don't need '/
	#define WIN32_LEAN_AND_MEAN
#elseif defined (__FB_LINUX__)
	#define HOST_LINUX
	#define HOST_UNIX
#elseif defined (__FB_FREEBSD__)
	#define HOST_FREEBSD
	#define HOST_UNIX
#elseif defined (__FB_NETBSD__)
	#define HOST_NETBSD
	#define HOST_UNIX
#elseif defined (__FB_OPENBSD__)
	#define HOST_OPENBSD
	#define HOST_UNIX
#elseif defined (__FB_DARWIN__)
	#define HOST_DARWIN
	#define HOST_UNIX
#elseif (Defined (sun) Or Defined (__sun)) And defined (__SVR4)
	#define HOST_SOLARIS
	#define HOST_UNIX
#else
	#error "Couldn't identify target system!"
#endif

#ifdef HOST_UNIX
	/' Map off_t/fopen/fseeko/etc. to their 64bit versions '/
	#define _FILE_OFFSET_BITS 64
#endif

#if defined (__FB_64BIT__)
	#define HOST_X86_64
	#define HOST_64BIT
#elseif defined (__sparc__)
	#ifdef __LP64__
		#define HOST_64BIT
	#endif
#elseif defined (__ppc64__)
	#define HOST_64BIT
#elseif defined (__aarch64__)
	#define HOST_64BIT
#else
	#define HOST_X86
#endif

/' This may be un-needed.  Will leave here until sure.
#ifdef HOST_MINGW
	/' work around gcc bug 52991 '/
	/' Since MinGW gcc 4.7, structs default to "ms_struct" instead of
	   "gcc_struct" as on Linux, and it seems like "packed" is broken in
	   combination with "ms_struct", so it's necessary to specify
	   "gcc_struct" explicitly. "gcc_struct" isn't recognized on all gcc
	   targets though, so we can't use it *all* the time. Thus we use it
	   only for MinGW (both 32bit and 64bit). '/
	#define FBPACKED __attribute__((gcc_struct, packed))
#else
	#define FBPACKED __attribute__((packed))
#Endif'/

#endif