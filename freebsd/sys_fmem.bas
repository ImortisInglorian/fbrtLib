/' fre() function '/

#include "../fb.bi"
#include "sys/sysctl.bi"
#include "sys/vmmeter.bi"
#include "vm/vm_param.bi"

Extern "c"
Function fb_GetMemAvail FBCALL ( mode as long ) as size_t

	dim mib(0 to 1) as long = { CTL_VM, VM_TOTAL }
	dim vmt as vmtotal
	dmi size as size_t = sizeof(vmtotal)

	if( sysctl( @mib(0), 2, @vmt, @size, NULL, 0 ) ) then return 0

	return vmt.t_free * sysconf( _SC_PAGE_SIZE )
End Function
End Extern