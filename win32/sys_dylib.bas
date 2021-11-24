/' Dynamic library loading functions '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_DylibLoad FBCALL ( library as FBSTRING ptr ) as any ptr
	dim as any ptr res = NULL

	if( library <> 0 andalso library->data <> 0 ) then
		res = LoadLibrary( library->data )
	end if

	/' del if temp '/
	fb_hStrDelTemp( library )

	return res
end function

function fb_DylibSymbol FBCALL ( library as any ptr, symbol as FBSTRING ptr ) as any ptr
	dim as any ptr proc = NULL
	dim as ZString*1024 procname
        dim as HINSTANCE hInstLibrary = cast(HINSTANCE, library)
	dim as long i

	if ( library = NULL ) then
		hInstLibrary = GetModuleHandle( NULL )
	end if

	if ( symbol <> 0 and symbol->data <> 0 ) then
		proc = GetProcAddress( hInstLibrary, symbol->data )
		if ( ( proc = NULL ) andalso ( strchr( symbol->data, Asc( "@" ) ) = 0 ) ) then
			procname[1023] = 0
			for i = 0 to 255 step 4
				snprintf( procname, 1023, "%s@%d", symbol->data, i )
				proc = GetProcAddress( hInstLibrary, procname )
				if ( proc ) then
					exit for
				end if
			next
		end if
	end if

	/' del if temp '/
	fb_hStrDelTemp( symbol )

	return proc
end function

function fb_DylibSymbolByOrd FBCALL ( library as any ptr, symbol as short ) as any ptr
	dim as any ptr proc = NULL

	if ( library = NULL ) then
		library = GetModuleHandle( NULL )
	end if

	proc = GetProcAddress( cast(HINSTANCE, library), MAKEINTRESOURCE(symbol) )

	return proc
end function

sub fb_DylibFree FBCALL ( library as any ptr )
	FreeLibrary(cast(HINSTANCE, library))
end sub
end extern