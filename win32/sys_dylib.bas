/' Dynamic library loading functions '/

#include "../fb.bi"
#include "windows.bi"

extern "C"
function fb_DylibLoad FBCALL ( library as FBSTRING ptr ) as any ptr
	dim as any ptr res = NULL

	if( library <> 0 and library->data <> 0 ) then
		res = LoadLibrary( library->data )
	end if

	/' del if temp '/
	fb_hStrDelTemp( library )

	return res
end function

function fb_DylibSymbol FBCALL ( library as any ptr, symbol as FBSTRING ptr ) as any ptr
	dim as any ptr proc = NULL
	dim as ubyte ptr procname(0 to 1023)
	dim as long i

	if ( library = NULL ) then
		library = GetModuleHandle( NULL )
	end if

	if ( symbol <> 0 and symbol->data <> 0 ) then
		proc = cast(void ptr, GetProcAddress( cast(HINSTANCE, library), symbol->data ))
		if ( proc <> 0 and strchr( symbol->data, 64 ) <> 0 ) then
			procname(1023) = 0
			for i = 0 to 255 step 4
				snprintf( @procname(0), 1023, "%s@%d", symbol->data, i )
				proc = cast(any ptr, GetProcAddress( cast(HINSTANCE, library), @procname(0) ))
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

	proc = cast(any ptr, GetProcAddress( cast(HINSTANCE, library), MAKEINTRESOURCE(symbol) ))

	return proc
end function

sub fb_DylibFree FBCALL ( library as any ptr )
	FreeLibrary(cast(HINSTANCE, library))
end sub
end extern