/' x86 processor identification '/

#include "../fb_config.bi"

'' Remove fbc's intrinsic definition
'' of declare function fb_CpuDetect cdecl( ) as ulong
#undef fb_CpuDetect

extern "c"
	declare function fb_CpuDetect naked () as ulong

	/' bits  0-27: low 24 bits of feature flags (CPUID eax = 1, edx) '/
	/' bits 28-31: cpu family (3 = 386, 4 = 486, 5 = 586, 6 = 686) '/

	dim shared detected_cpu as ulong = 0
end extern

function fb_CpuDetect naked () as ulong

asm
	mov eax, [detected_cpu]
	or eax, eax
	jz detect

	ret /' already detected (return detected_cpu) '/

detect:
	push ebp
	mov ebp, esp
	push ebx
	push edi
	push esi

	/' check for CPUID availability (try toggling bit 21 of EFLAGS) '/
	pushfd
	pop eax
	mov edx, eax
	xor eax, 0x200000
	push eax
	popfd
	pushfd
	pop eax
	xor eax, edx
	jnz cpuid_ok

	/' no CPUID; assume 386 and check if 486 (try toggling bit 18 (AC) of EFLAGS) '/
	mov ebx, 0x30000000
	mov ecx, esp
	and esp, 0xFFFFFFFB /' round ESP down to a multiple of 4 (must be aligned if AC becomes enabled) '/
	pushfd
	pop eax
	mov edx, eax
	xor eax, 0x40000
	push eax
	popfd
	pushfd
	pop eax
	xor eax, edx
	mov esp, ecx
	jz cpu486_not_found

	mov ebx, 0x40000000

cpu486_not_found:
	push edx
	popf
	mov eax, ebx
	jmp cpudetect_exit

cpuid_ok:
	mov eax, 1
	cpuid
	shl eax, 20
	and edx, 0x0FFFFFFF /' low 28 bits of feature flags '/
	or eax, edx

cpudetect_exit:

	mov [detected_cpu], eax

	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
end asm

end function