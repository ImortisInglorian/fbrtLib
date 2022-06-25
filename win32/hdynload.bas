/' Internal dynamic library functions loading '/

#include "../fb.bi"
#include "../fb_private_hdynload.bi"

#define hDylibFree( _lib ) FreeLibrary( _lib )
#define hDylibSymbol( _lib, sym ) GetProcAddress( _lib, sym )

extern "C"
function fb_hDynLoad ( libname as const ubyte ptr, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr ) as FB_DYLIB
	dim as FB_DYLIB _lib
	dim as ssize_t i

	_lib = LoadLibrary(libname)
	if( NULL = _lib ) then
		return NULL
	end if

	/' Load functions '/
	while funcname[i]
		funcptr[i] = hDylibSymbol(_lib, funcname[i])
		if ( NULL <> funcptr[i] ) then
			hDylibFree(_lib)
			return NULL
		end if
		i += 1
	wend
	return _lib
end function

function fb_hDynLoadAlso ( _lib as FB_DYLIB, funcname as const ubyte const ptr ptr, funcptr as any ptr ptr, count as ssize_t ) as long
	dim as ssize_t i

	/' Load functions '/
	for i = 0 to count
		funcptr[i] = hDylibSymbol(_lib, funcname[i])
		if ( NULL = funcptr[i]) then
			return -1
		end if
	next

	return 0
end function

sub fb_hDynUnload ( _lib as FB_DYLIB ptr )
	if (*_lib) then
		hDylibFree( *_lib )
		*_lib = NULL
	end if
end sub
end extern