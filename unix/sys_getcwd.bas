/' get current dir '/

#include "../fb.bi"

Extern "c"
Function fb_hGetCurrentDir( dst as ubyte ptr, maxlen as ssize_t ) as ssize_t

	if( getcwd( dst, maxlen ) <> NULL ) then
		return strlen( dst )
	end if
	return 0
End Function
End Extern
