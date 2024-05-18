/' libfb initialization for Windows '/

#include "../fb.bi"
#include "fb_private_console.bi"

extern "C"

#ifdef ENABLE_MT
dim shared as CRITICAL_SECTION __fb_global_mutex
dim shared as CRITICAL_SECTION __fb_string_mutex
dim shared as CRITICAL_SECTION __fb_mtcore_mutex
dim shared as CRITICAL_SECTION __fb_graphics_mutex
dim shared as CRITICAL_SECTION __fb_math_mutex
dim shared as CRITICAL_SECTION __fb_profile_mutex

sub fb_Lock FBCALL ( )
	EnterCriticalSection( @__fb_global_mutex )
end sub

sub fb_Unlock FBCALL ( )
	LeaveCriticalSection( @__fb_global_mutex )
end sub

sub fb_StrLock FBCALL ( )
	EnterCriticalSection( @__fb_string_mutex )
end sub

sub fb_StrUnlock FBCALL ( )
	LeaveCriticalSection( @__fb_string_mutex )
end sub

sub fb_MtLock FBCALL ( )
	EnterCriticalSection( @__fb_mtcore_mutex )
end sub

sub fb_MtUnlock FBCALL ( )
	LeaveCriticalSection( @__fb_mtcore_mutex )
end sub

sub fb_GraphicsLock FBCALL ( )
	EnterCriticalSection( @__fb_graphics_mutex )
end sub

sub fb_GraphicsUnlock FBCALL ( )
	LeaveCriticalSection( @__fb_graphics_mutex )
end sub

sub fb_MathLock FBCALL ( )
	EnterCriticalSection( @__fb_math_mutex )
end sub

sub fb_MathUnlock FBCALL ( )
	LeaveCriticalSection( @__fb_math_mutex )
end sub

sub fb_ProfileLock FBCALL ( )
	EnterCriticalSection( @__fb_profile_mutex )
end sub

sub fb_ProfileUnlock FBCALL ( )
	LeaveCriticalSection( @__fb_profile_mutex )
end sub

#endif

dim shared as FB_CONSOLE_CTX __fb_con /' not initialized '/

sub fb_hInit( )
	#ifdef HOST_X86
		dim as ushort FPUControlWord
		' Get FPU control word
		asm fstcw [FPUControlWord]
		' Set 64-bit and round to nearest
		FPUControlWord = (FPUControlWord and &HF0FF) or &H0300
		' Write back FPU control word
		asm fldcw [FPUControlWord]
	#elseif defined(HOST_X86_64) 
		dim as ushort FPUControlWord
		' Get FPU control word
		asm fstcw [FPUControlWord]
		' Set 64-bit and round to nearest
		FPUControlWord = (FPUControlWord and &HF0FF) or &H0300
		' Write back FPU control word
		asm fldcw [FPUControlWord]
	#endif

#ifdef ENABLE_MT
	InitializeCriticalSection(@__fb_global_mutex)
	InitializeCriticalSection(@__fb_string_mutex)
	InitializeCriticalSection(@__fb_mtcore_mutex)
	InitializeCriticalSection(@__fb_graphics_mutex)
	InitializeCriticalSection(@__fb_math_mutex)
	InitializeCriticalSection(@__fb_profile_mutex)
#endif

	memset( @__fb_con, 0, sizeof( FB_CONSOLE_CTX ) )
end sub

sub fb_hEnd( unused as long )
#ifdef ENABLE_MT
	DeleteCriticalSection(@__fb_global_mutex)
	DeleteCriticalSection(@__fb_string_mutex)
	DeleteCriticalSection(@__fb_mtcore_mutex)
	DeleteCriticalSection(@__fb_graphics_mutex)
	DeleteCriticalSection(@__fb_math_mutex)
	DeleteCriticalSection(@__fb_profile_mutex)
#endif
end sub
end extern