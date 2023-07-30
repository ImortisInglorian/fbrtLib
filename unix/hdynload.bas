/' Internal dynamic library functions loading '/

#include "../fb.bi"
#include "../fb_private_hdynload.bi"

#include "dlfcn.bi"
#define hDylibFree( lib ) dlclose( lib )
#define hDylibSymbol( lib, sym ) dlsym( lib, sym )

Extern "c"
Function fb_hDynLoad(libname as const ubyte ptr, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr) As FB_DYLIB

	dim lib as FB_DYLIB
	dim i as ssize_t

	/' First look if library was already statically linked with current executable '/
	lib = dlopen(NULL, RTLD_LAZY)
	if ( lib = Null ) then
		return NULL
	end if
	if ( dlsym( lib, funcname[0] ) = 0 ) then
		dlclose( lib )
		lib = dlopen(libname, RTLD_LAZY)
		if ( lib = Null ) then
			return NULL
		end if
	end if

	/' Load functions '/
	i = 0
	While funcname[i] <> Null 
		funcptr[i] = hDylibSymbol( lib, funcname[i] )
		if (funcptr[i] = Null) then
			hDylibFree(lib)
			return NULL
		end if
		i += 1
	Wend

	return lib
End Function

Function fb_hDynLoadAlso( lib As FB_DYLIB, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr, count as ssize_t ) As Long

	/' Load functions '/
	for i As ssize_t = 0 to count - 1
		funcptr[i] = hDylibSymbol( lib, funcname[i] )
		if ( funcptr[i] = Null ) then
			return -1
		end if
	next

	return 0
End Function

Sub fb_hDynUnload( lib as FB_DYLIB ptr )

	if ( lib <> Null AndAlso *lib <> Null ) then
		hDylibFree( *lib )
		*lib = NULL
	end if
End Sub
End Extern